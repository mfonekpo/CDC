FROM debezium/connect:3.0.0.Final

# create directory
RUN mkdir -p /kafka/connect/snowflake

# Install snowflake-kafka-connector
# COPY snowflake/snowflake-kafka-connector-4.1.0.jar \
#     /kafka/connect/snowflake/

# # Install Bouncy Castle Dependencies
# COPY snowflake/bc-fips-2.1.0.jar /kafka/connect/snowflake/

# COPY snowflake/bcpkix-fips-2.1.8.jar /kafka/connect/snowflake/

RUN curl -fSL -o /kafka/connect/snowflake/snowflake-kafka-connector-4.1.0.jar \
    https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/4.1.0/snowflake-kafka-connector-4.1.0.jar

RUN curl -fSL -o /kafka/connect/snowflake/bc-fips-2.1.0.jar \
    https://repo1.maven.org/maven2/org/bouncycastle/bc-fips/2.1.0/bc-fips-2.1.0.jar

RUN curl -fSL -o /kafka/connect/snowflake/bcpkix-fips-2.1.8.jar \
    https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-fips/2.1.8/bcpkix-fips-2.1.8.jar