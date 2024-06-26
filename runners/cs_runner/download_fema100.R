# Running this script goes and pulls the desired FEMA100 flood fgb datasets from the lynker-hydrofabric S3 bucket then saves them into a directory within "base_dir"
# base_dir is defined within runners/workflow/root_dir.R

# NOTE: The lynker-hydrofabric S3 bucket is private at the moment

# load config variables
source("runners/cs_runner/config_vars.R")

# -------------------------------------------------------------------------------------
# ---- Create FEMA100/ directory and bounding box dir (if it does NOT exist) ----
# -------------------------------------------------------------------------------------

if (!dir.exists(FEMA_FGB_PATH)) {
  message(paste0("FEMA100/ directory does not exist...\nCreating directory:\n > '", FEMA_FGB_PATH, "'"))
  dir.create(FEMA_FGB_PATH)
}

# create geojsons directory (if not exists) 
if (!dir.exists(FEMA_GEOJSON_PATH)) {
  message(paste0(FEMA_GEOJSON_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_GEOJSON_PATH, "'"))
  dir.create(FEMA_GEOJSON_PATH)
}

# create directory for cleaned FEMA geometries (if not exists) 
if (!dir.exists(FEMA_CLEAN_PATH)) {
  message(paste0(FEMA_CLEAN_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_CLEAN_PATH, "'"))
  dir.create(FEMA_CLEAN_PATH)
}

# create directory for cleaned FEMA geometries as geopackages (if not exists) 
if (!dir.exists(FEMA_GPKG_PATH)) {
  message(paste0(FEMA_GPKG_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_GPKG_PATH, "'"))
  dir.create(FEMA_GPKG_PATH)
}

# create simplified geojsons directory (if not exists)
if (!dir.exists(FEMA_SIMPLIFIED_PATH)) {
  message(paste0(FEMA_SIMPLIFIED_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_SIMPLIFIED_PATH, "'"))
  dir.create(FEMA_SIMPLIFIED_PATH)
}

# create simplified geojsons directory (if not exists)
if (!dir.exists(FEMA_DISSOLVED_PATH)) {
  message(paste0(FEMA_DISSOLVED_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_DISSOLVED_PATH, "'"))
  dir.create(FEMA_DISSOLVED_PATH)
}

# create exploded geojsons directory (if not exists)
if (!dir.exists(FEMA_EXPLODED_PATH)) {
  message(paste0(FEMA_EXPLODED_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_EXPLODED_PATH, "'"))
  dir.create(FEMA_EXPLODED_PATH)
}

# create FEMA GPKG Bounding Boxes directory (if not exists)
if (!dir.exists(FEMA_GPKG_BB_PATH)) {
  message(paste0(FEMA_GPKG_BB_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_GPKG_BB_PATH, "'"))
  dir.create(FEMA_GPKG_BB_PATH)
}

if (!dir.exists(FEMA_FGB_BB_PATH)) {
  message(paste0(FEMA_FGB_BB_PATH, " directory does not exist...\nCreating directory:\n > '", FEMA_FGB_BB_PATH, "'"))
  dir.create(FEMA_FGB_BB_PATH)
}

# -------------------------------------------------------------------------------------
# ---- Get list of FEMA FGB files in S3 bucket ----
# -------------------------------------------------------------------------------------

# list objects in S3 bucket, and regular expression match to nextgen_.gpkg pattern
fema_list_command <- paste0('#!/bin/bash
            # AWS S3 Bucket and Directory information
            S3_BUCKET="', FEMA_S3_DIR, '" 
            
            # Regular expression pattern to match object keys
            PATTERN=".fgb$"
            
            # AWS CLI command to list objects in the S3 bucket and use grep to filter them
            S3_OBJECTS=$(aws s3 ls "$S3_BUCKET" --profile ', aws_profile, ' | awk \'{print $4}\' | grep -E "$PATTERN")
            
            echo "$S3_OBJECTS"'
)

# -------------------------------------------------------------------------------------
# ---- Get the S3 buckets object keys for FEMA 100 FGB files ----
# -------------------------------------------------------------------------------------

# Run the script to get a list of the nextgen geopackages that matched the regular expression above
FEMA_BUCKET_KEYS <- system(fema_list_command, intern = TRUE)

# create bucket object URIs
# FEMA_BUCKET_OBJECTS <- paste0(FEMA_S3_BUCKET, FEMA_S3_BUCKET_PREFIX, FEMA_BUCKET_KEYS)

# -------------------------------------------------------------------------------------
# ---- Download FEMA 100 year FGB files from S3 ----
# -------------------------------------------------------------------------------------

# Parse the selected S3 objects keys from the FEMA100 bucket directory copy them to the local destination directory if the file does NOT exist yet
for (key in FEMA_BUCKET_KEYS) {
  local_save_path <- paste0(FEMA_FGB_PATH, "/", key)
  
  if(!file.exists(local_save_path)) {
    copy_cmd <- paste0('aws s3 cp ', FEMA_S3_BUCKET, FEMA_S3_BUCKET_PREFIX, key, " ", local_save_path, " --profile ", aws_profile)
    
    message("S3 object:\n > '", FEMA_S3_BUCKET, FEMA_S3_BUCKET_PREFIX, key, "'")
    message("Downloading S3 object to:\n > '", local_save_path, "'")
    # message("Copy command:\n > '", copy_cmd, "'")
    
    # system(copy_cmd)
    
    message(" > '", key, "' download complete!")
    message("----------------------------------")
  } else {
    message("File already exists at:\n > '", local_save_path, "'")
  }
}



  




