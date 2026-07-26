import requests
import json
import os
from utils.logging_conf import logger
from src.validate import AirQualityReading, AirqualityFetchError
from tenacity import retry, stop_after_attempt, wait_exponential
from dotenv import load_dotenv

from pydantic import ValidationError


load_dotenv()

WEATHERAPI = os.getenv("WEATHERAPI")
LAT = os.getenv("LAT")
LONG = os.getenv("LONG")

def validate_env():
    if not all([WEATHERAPI, LAT, LONG]):
        raise EnvironmentError(
            "Missing required environment variables. Please check the .env file."
            "WEATHERAPI, LAT, LONG must all be set"
        )

API_URL = "http://api.openweathermap.org/data/2.5/air_pollution"


@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
def fetch_air_quality() -> dict:
    """
    Fetch layer — only responsibility is making the HTTP request
    and returning a validated, serialised reading.
    Has zero knowledge of storage or alerting.
    """

    validate_env()

    payload = {
        "lat": LAT,
        "lon": LONG,
        "appid": WEATHERAPI,
    }

    try:
        response = requests.get(API_URL, params=payload, timeout=(30, 30))
        response.raise_for_status()
        resp_dict = response.json().get("list", [])[0]

    except requests.exceptions.Timeout:
        logger.error("The request timed out")
        raise AirqualityFetchError("The request timed out")

    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP error occurred: {e}")
        raise AirqualityFetchError(f"HTTP error: {e}")

    except requests.exceptions.RequestException as e:
        logger.error(f"An error occurred: {e}")
        raise AirqualityFetchError(f"Request failed: {e}")

    except json.JSONDecodeError:
        logger.error("Failed to decode JSON response")
        raise AirqualityFetchError("Failed to decode JSON response")

    else:
        logger.info("API request successful")

        aqi = resp_dict.get("main", {}).get("aqi")
        date = resp_dict.get("dt")
        co_value = resp_dict.get("components", {}).get("co")
        ozone_value = resp_dict.get("components", {}).get("o3")

        try:
            reading = AirQualityReading(
                aqi=aqi,
                date=date,
                co_value=co_value,
                ozone_value=ozone_value,
            )
        except ValidationError as e:
            logger.error(f"Data validation failed: {e}")
            raise AirqualityFetchError(f"Data validation failed: {e}")

        return reading.model_dump()