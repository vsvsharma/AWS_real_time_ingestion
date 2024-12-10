import sys
from datetime import datetime, timedelta
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql.functions import col, input_file_name, regexp_extract
from awsglue.dynamicframe import DynamicFrame

class DataIngestion:
    def __init__(self,glue_context,db_name, tbl_name, previous_day_partition, predicate):
        self.glue_context=glue_context
        self.db_name=db_name
        self.tbl_name=tbl_name
        self.previous_day_partition=previous_day_partition
        self.predicate=predicate

    def fetch_raw_data(self):
        
        dynamic_frame=self.glue_context.create_dynamic_frame.from_catalog(database=self.db_name, table_name=self.tbl_name, push_down_predicate=self.predicate)

        return dynamic_frame.toDF()
    
class DataTransformation:
    def __init__(self,raw_df):
        self.raw_df=raw_df

    def personal_details(self):

        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.gender").alias("gender"), col("results.name.title").alias("title"), col("results.name.first").alias("first_name"), col("results.name.last").alias("last_name"), col("results.email").alias("email"), col("results.dob.date").alias("date_of_birth"), col("results.dob.age").alias("age"), col("results.phone").alias("phone"), col("results.cell").alias("cell"), col("partition_0").alias("p_date"))
    
    def address(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.location.street.name").alias("street_name"), col("results.location.street.number").alias("street_number"), col("results.location.city").alias("city"), col("results.location.state").alias("state"), col("results.location.country").alias("country"), col("partition_0").alias("p_date"))
    
    def picture(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.picture.large").alias("profile_picture_large"), col("results.picture.medium").alias("profile_picture_medium"), col("results.picture.thumbnail").alias("profile_picture_thumbnail"), col("partition_0").alias("p_date"))
    
    def login(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.login.username").alias("username"), col("results.login.password").alias("password"), col("partition_0").alias("p_date"))
    
    def location(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.location.coordinates.latitude").alias("latitude"), col("results.location.coordinates.longitude").alias("longitude"), col("results.location.timezone.offset").alias("timezone_offset"), col("results.location.timezone.description").alias("timezone_description"), col("partition_0").alias("p_date"))
    
    def registration(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.registered.date").alias("registration_date"), col("results.registered.age").alias("registration_age"), col("partition_0").alias("p_date"))
    
    def encyrpted_details(self):
        return self.raw_df.select(col("results.login.uuid").alias("uuid"), col("results.login.salt").alias("salt"), col("results.login.md5").alias("md5"), col("results.login.sha1").alias("sha1"), col("results.login.sha256").alias("sha256"), col("partition_0").alias("p_date"))
    
class Datawriter:
    def __init__(self,glue_context, s3_target_path):
        self.glue_context=glue_context
        self.s3_target_path=s3_target_path

    def write_to_s3(self,transformed_df):
        dynamic_frame = DynamicFrame.fromDF(transformed_df, self.glue_context, "dynamic_frame")
        
        self.glue_context.write_dynamic_frame.from_options(frame=dynamic_frame, connection_type="s3", connection_options={"path":self.s3_target_path, "partitionKeys":["p_date"]}, format="parquet", transformation_ctx="write_to_s3")
        print(f"Successfully written to table : {self.s3_target_path}")

#Initialzation
sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
#Glue database and table name
db_name="extraction_database"
tbl_name="user_data_raw_layer"

today=datetime.today()
previous_day=today - timedelta(days=1)
previous_day_partition=previous_day.strftime('%Y-%m-%d')
predicate=f"partition_0='{previous_day_partition}'"

#Data Ingestion
ingestion=DataIngestion(glue_context, db_name, tbl_name, previous_day_partition, predicate)
raw_df=ingestion.fetch_raw_data()

#Data Transformation
transformation=DataTransformation(raw_df)
personal_details_df=transformation.personal_details()
address_df=transformation.address()
picture_df=transformation.picture()
login_df=transformation.login()
location_df=transformation.location()
registration_df=transformation.registration()
encrypted_details_df=transformation.encyrpted_details()

#Data Writing to the transform layer s3 path

#defining particular directories
data_types={
    "personal_details":personal_details_df,
    "address":address_df,
    "picture":picture_df,
    "login":login_df,
    "location":location_df,
    "registration":registration_df,
    "encrypted_details":encrypted_details_df
}

#Writing data to S3
s3_target_path="user-data-transform-layer"
for data_type, df in data_types.items():
    path=f"s3://{s3_target_path}/{data_type}"
    writer=Datawriter(glue_context,path)
    writer.write_to_s3(df)
