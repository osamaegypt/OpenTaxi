import Axios from "axios";
import { DRIVER_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { ACCOUNT, DRIVER } from "./_fakedata";
import { execQuery } from "../src/db";
import { cloneObjec, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => DRIVER_URL + queryParams;

const createDriver = async () => {
  const response = await Axios.post(DRIVER_URL, {
    account: ACCOUNT,
    driver: DRIVER
  });
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: DRIVER", () => {
  beforeEach(async () => {
    await execQuery("DELETE FROM account");// Deleting the account will delete the
    // driver data too, because a CASCADE constraint is specified on the account_id
    // column.
  });

  it("Should successfully create a driver.", createDriver);

  it("Should successfully get a driver.", async () => {
    await createDriver(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?account_id=" + DRIVER.account_id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(DRIVER));
  });

  it("Should successfully update an driver.", async () => {
    await createDriver(); // Create it first
    const newDriver = cloneObjec(DRIVER);
    newDriver.id_url = "lkjfls";
    newDriver.alternative_phone_number = 3646375432;

    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + DRIVER.account_id),
      newDriver
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of a driver.", async () => {
    // await createDriver(); // Create it first

    // // End then update it.
    // const response = await Axios.put(getUrlWithQuery("/" + DRIVER.account_id), {
    //   surname: "Musk",
    // });
    // expect(response.status).toBe(200);
    // expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete a driver.", async () => {
    await createDriver(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + DRIVER.account_id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
