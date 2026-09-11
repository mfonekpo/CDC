from src.elt.fetch import fetch_air_quality


def main():
    air_quality = fetch_air_quality()
    print(air_quality)

if __name__ == "__main__":
    main()