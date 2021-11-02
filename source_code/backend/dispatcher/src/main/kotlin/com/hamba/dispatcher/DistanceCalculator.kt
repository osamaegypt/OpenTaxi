package com.hamba.dispatcher

import com.hamba.dispatcher.model.*
import dilivia.s2.S1Angle
import dilivia.s2.S2Earth
import dilivia.s2.index.S2MinDistance
import dilivia.s2.index.S2MinDistancePointTarget
import dilivia.s2.index.point.S2ClosestPointQuery
import kotlinx.coroutines.runBlocking

class DistanceCalculator(private val driverDataManager: DriverDataManager, private val routeApiClient: RouteApiClient) {

    private val distanceCalculator = S2ClosestPointQuery(
        driverDataManager.locationIndex,
        S2ClosestPointQuery.Options(maxDistance = S2MinDistance(S1Angle.degrees(S2Earth.kmToRadians(3.0))))
    )

    private val availableUpdates = mutableListOf<() -> Unit>()

    init {
        val dataChangeListener = DataChangeListener(
            onDataAdded = distanceCalculator::reInit,
            onDataDeleted = distanceCalculator::reInit,
            onDataUpdateNeeded = availableUpdates::add,
        )
        driverDataManager.addDataChangeListener(dataChangeListener)
    }

    fun getClosestDriverDistance(requestData: DispatchRequestData): List<Pair<DriverData, Element>> {
        var closestDriverAsTheCrowFlies: List<DriverData>
        synchronized(this) {
            closestDriverAsTheCrowFlies = if (requestData.gender.isBlank() && requestData.carType.isNotBlank()) {
                findClosestDistanceAsTheCrowFlies(requestData.location)
            } else {
                findClosestDistanceAsTheCrowFlies(requestData)
            }
            availableUpdates.forEach { updateData -> updateData() }
        }
        return findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.location)
    }

    private fun findClosestDistanceAsTheCrowFlies(data: DispatchRequestData): List<DriverData> {
        val target = S2MinDistancePointTarget(data.location.toS2Point())
        val closestPoint = distanceCalculator.findClosestPoints(target).filter {
            val driverData = driverDataManager.getDriverData(it.data())
            if (data.gender.isNotBlank() && data.gender != driverData?.gender) {
                return@filter false
            }
            if (data.carType.isNotBlank() && data.carType != driverData?.carType) {
                return@filter false
            }
            true
        }
        if (closestPoint.isEmpty()) {
            return emptyList()
        }
        val closestDriver = closestPoint.sorted()
        val result = mutableListOf<DriverData>()
        var driverData: DriverData
        repeat(4) {
            driverData = driverDataManager.getDriverData(closestDriver[it].data())!!
            // TODO Handle the case the driverDataManager return null ^.
            result.add(driverData)
        }
        return result
    }

    private fun findClosestDistanceAsTheCrowFlies(location: Location): List<DriverData> {
        val target = S2MinDistancePointTarget(location.toS2Point())
        distanceCalculator.options().setMaxResult(4)
        val closestPoint = distanceCalculator.findClosestPoints(target)
        return closestPoint.map { driverDataManager.getDriverData(it.data())!! }// TODO Handle the case the driverDataManager return null.
    }

    private fun findClosestDistanceOnRoad(
        driversData: List<DriverData>,
        riderLocation: Location
    ): List<Pair<DriverData, Element>> {
        val driverLocations = driversData.map { it.location }
        val closestDriver = mutableListOf<Pair<DriverData, Element>>()
        runBlocking {
            val orderedDistanceMatrixElement = routeApiClient.distanceMatrix(driverLocations, riderLocation)
            repeat(driversData.size){
                closestDriver.add(Pair(driversData[it], orderedDistanceMatrixElement[it]))
            }
        }
        return closestDriver
    }

}