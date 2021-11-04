package com.hamba.dispatcher

import com.hamba.dispatcher.model.DispatchRequestData
import com.hamba.dispatcher.model.DriverData
import com.hamba.dispatcher.model.Location

val fakeDriverData = DriverData("nearSala", Location(11.310777, -12.312727)/*Near SALA*/, "MALE", "STANDARD")

val fakeDriverDataList = mutableListOf<DriverData>().apply {
    add(fakeDriverData)
    add(DriverData("nearHome", Location(11.307769, -12.315753) /*NEAR HOME*/, "FEMALE", "STANDARD"))
    add(DriverData("garageMalal", Location(11.312763, -12.320231) /*GARAGE MALAL*/, "MALE", "PREMIUM"))
    add(DriverData("pharmacieNdiolou", Location(14.345643, -11.463644)  /*PHARMACIE N'DIOLOU (FACE PERGOLA)*/, "MALE", "STANDARD"))
    add(DriverData("garambe", Location(11.259205, -12.367215) /*GARAMDBE*/  , "MALE", "VAN"))
    add(DriverData("timbo", Location(11.224548, -12.353052) /*TIMBO*/  , "FEMALE", "LITE"))
    add(DriverData("labeAirport", Location(11.330455, -12.295603) /*LABE AIRPORT*/  , "FEMALE", "STANDARD"))
}

val fakeDispatchRequestData = DispatchRequestData(
    "riderId",
    Location(11.309098, -12.318813)/*HOME*/,
    listOf("11.313145, -12.315527"/*BASEL*/),
    "11.314165, -12.300839"/*YALI*/
)