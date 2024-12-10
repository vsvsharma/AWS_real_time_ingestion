variable "tables" {
  type = list(object({
    name          = string
    location      = string
    columns       = list(object({
      name = string
      type = string
    }))
    comment       = string
    database      = string
    partition_keys = list(object({
      name = string
      type = string
    }))
  }))
  default = [
    {
      name          = "extraction_table"
      location      = "s3://user-data-raw-layer/"
      columns       = [
        { name= "results", type= "array<struct<cell:string,dob:struct<age:bigint,date:string>,email:string,gender:string,id:struct<name:string,value:string>,location:struct<city:string,coordinates:struct<latitude:string,longitude:string>,country:string,state:string,street:struct<name:string,number:bigint>,timezone:struct<description:string,offset:string>>,login:struct<md5:string,password:string,salt:string,sha1:string,sha256:string,username:string,uuid:string>,name:struct<first:string,last:string,title:string>,nat:string,phone:string,picture:struct<large:string,medium:string,thumbnail:string>,registered:struct<age:bigint,date:string>>>"},
        { name= "info", type="struct<page:bigint,results:bigint,seed:string,version:string>" },
        {name="p_time", type="string"}
      ]
      comment       = "This is extraction table"
      database      = "extraction_database"
      partition_keys = [
        { name = "p_date",  type = "string" },
      ]
    },
    {
      name          = "address"
      location      = "s3://user-data-transform-layer/address/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="street_number", type="array<bigint>"},
        {name="street_name", type="array<string>"},
        {name="city",type="array<string>"},
        {name="state", type="array<string>"},
        {name="country", type="array<string>"}
      ]
      comment       = "This is address table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "encrypted_details"
      location      = "s3://user-data-transform-layer/encrypted_details/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="salt", type="array<string>"},
        {name="md5", type="array<string>"},
        {name="sha1",type="array<string>"},
        {name="sha256", type="array<string>"}
      ]
      comment       = "This is encrypted details table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "location"
      location      = "s3://user-data-transform-layer/location/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="latitude", type="array<string>"},
        {name="longitude", type="array<string>"},
        {name="timezone_offset", type="array<string>"},
        {name="timezone_description", type="array<string>"}
      ]
      comment       = "This is location table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "login"
      location      = "s3://user-data-transform-layer/login/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="login", type="array<string>"},
        {name="password", type="array<string>"}
      ]
      comment       = "This is login table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "personal_details"
      location      = "s3://user-data-transform-layer/personal_details/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="gender", type="array<string>"},
        {name="title", type="array<string>"},
        {name="first_name", type="array<string>"},
        {name="last_name", type="array<string>"},
        {name="email", type="array<string>"},
        {name="date_of_birth", type="array<string>"},
        {name="age", type="array<bigint>"},
        {name="phone", type="array<string>"},
        {name="cell", type="array<string>"}
      ]
      comment       = "This is personal details table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "picture"
      location      = "s3://user-data-transform-layer/picture/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="profile_picture_large", type="array<string>"},
        {name="profile_picture_medium", type="array<string>"},
        {name="profile_picture_thumbnail", type="array<string>"}
      ]
      comment       = "This is picture table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    },
    {
      name          = "registration"
      location      = "s3://user-data-transform-layer/registration/"
      columns       = [
        {name="uuid", type="array<string>"},
        {name="registration_age", type="array<bigint>"},
        {name="registration_date", type="array<string>"}
      ]
      comment       = "This is registration table"
      database      = "transform_layer_database"
      partition_keys = [
        { name = "p_date", type = "string" },
      ]
    }
  ]
}

variable "raw_layer_crawler_schedule" {
  description = "Schedule for the raw layer"
  type = string
  default = "cron(0 1 * * ? *)" #everyday at 1AM
}

variable "transform_layer_crawler_schedule" {
  description = "Schedule for the transform layer"
  type = string
  default = "cron(0 2 * * ? *)" #everyday at 2AM
}