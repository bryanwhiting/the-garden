
# IDEAS:
# You have a start and end date, but you could also have a "number of times". So if it's something you only want to do 5 days a week, you could specify that
# TOOD: summary by week?
# Todo: allow for future planning before the field day
# TODO: allow for harvest of last week's (so you can get a harvest on Sunday)
# TODO: g <no-option> will always pull back the last, but we only want this weeks. Last is easy to get, but we want to pull back the one from this week, if there is one.
# TODO: add functions so you can pull back last week's field
# g <no-option> should be "today's" view. g -t should summary
# TODO: add monthly visions.
# IDEA: consider incorporating daily statements into each g <> call.
# FIXME: Can't have streams or seeds with duplicate names
# FIXME: Is the left_join duplicating rows? The right has two values for "teaching", unique by date. Since you're merging onto the left, which only has "seed", it will naturally join the two rows.


args <- commandArgs(trailingOnly = T)

options(stringsAsFactors = F)
suppressMessages(library(dplyr))
suppressMessages(library(magrittr))
suppressMessages(library(knitr))

if (length(grep("Windows", sessionInfo()$running)) > 0) {
  system = "Windows"
  folder_path = "C:/Users/bwhiting/Dropbox/jrnl/garden"
} else {
  system = "Else"
  folder_path = "~/Dropbox/jrnl/garden"
}

# Make harvested
seed_path <- file.path(folder_path, "seeds")

field_day <- "Sunday"

# Get date of previous field day (Sunday) 
day <-  Sys.Date()
prev.days <- seq(day - 6, day, by='day')
field_day_date <- prev.days[weekdays(prev.days)== field_day]
harvest_day_date <- field_day_date + 6

# Log file
log_filename <- file.path(folder_path, "log.txt")
df_log <- read.table(log_filename, sep = "|", col.names = c("date", "finished"))
df_log$date %<>% as.Date("%Y-%m-%d")
df_log %<>% unique()

# Test for args
arg_ind_log <- grep("-l[0-9]?|-log[0-9]?", args)

# DATA PROCESSING ------------------------------------------------------------
# PROCESS STREAMS ------------------------------------------------------------
# Print active daily goals 
filename <- file.path(folder_path, "streams.txt")
df_streams <- read.table(filename, sep = "|")
names(df_streams) <- c("stream", "desc", "start", "end")
df_streams$start %<>% as.Date()
df_streams$end %<>% as.Date()

# Look at streams that haven't ended yet 
df_streams %<>% filter(Sys.Date() <= end)

# IDEA: How many days have you done this stream?
for (i in 1:nrow(df_streams)){
  # For each stream, count how many records lie between the dates 
  s <- df_streams[i, ]
  df_streams$cnt[i] <- df_log %>% filter(finished == s$stream) %>%
    filter(date >=s$start, date <=s$end) %>%
    count() %>%  as.numeric()
  
  # 0/1 for today?
  df_streams$thisday[i] <- df_log %>% filter(finished == s$stream) %>%
    filter(date == Sys.Date()) %>%
    count() %>% as.numeric()
  
  # Success this week
  df_streams$thisweek[i] <- df_log %>% filter(finished == s$stream) %>%
    filter(date >=s$start, date <=s$end) %>%
    filter(date >= field_day_date) %>%
    count() %>%  as.numeric()
  
} 
# How many cnts are possible? Each day is a possibility. 5/29 and 5/30 are two days.
df_streams$today <- Sys.Date()
df_streams$possible <- as.numeric(df_streams$today - df_streams$start) + 1
# stats
df_streams$streak <- paste(df_streams$cnt, "/", df_streams$possible, sep = "")
df_streams$rate <- (df_streams$cnt / df_streams$possible) %>% round(2)

# What's left after today
df_streams$left <- as.numeric(df_streams$end - df_streams$today)
df_streams$total <- as.numeric(df_streams$end - df_streams$start) + 1

# Convert week to be the ratio of days possible
ndays_since_field <- as.numeric(Sys.Date() - field_day_date) + 1
# ndays_since_field is number of days since last field day, but if you started your goal in the middle of the week, then don't count back to the field day. hence min(x, y).
df_streams %<>% mutate(thisweek = paste(thisweek, "/", min(ndays_since_field, possible), sep = ""))

# Prepare for output
df_streams$end %<>% format("%b %d")
df_streams$start %<>% format("%b %d")

# remove detail
df_streams %<>% select(-today)








# OPTIONS ----------------
if ("-help" %in% args) {
  cat("Options include:\n") 
  cat("    g -stream <name>: Add a new stream.\n") 
  cat("    g -seed <name>: Add a new seed.\n") 
  cat("    g -log <name1> <name2> ... <nameN>: Track streams, logs, and stones\n") 
  cat("    g -p 1 3 10: Plant seeds 1 3 10 today\n") 
  q()
}

# Add a new goal:
if ("-stream" %in% args) {
  # Ensure all the arguments are present. goal name | ndays
  
  # FIXME: Make sure the same stream can't be overlapping (no two streams with same name)
  
  if (length(args) <= 1) {
    cat("\nStream name:") 
    goal_name <- readLines(file("stdin"), 1)
  } else {
    goal_name = args[2] 
    cat("\nStream name:", goal_name, "\n") 
  }
  
  cat("Define your goal (must be binary):")
  desc <- readLines(file("stdin"), 1)
  if (length(desc) == 0 ) stop("Please enter a description.")
  
  cat("How many days:") 
  ndays <- as.numeric(readLines(file("stdin"), 1))
  
  # Create goal
  start <- Sys.Date()
  end <- start + ndays - 1 # Remove 1 because the start day counts as a possibility
  stream <- paste(goal_name, desc, start, end, sep = "|")
 
  # Append to file 
  filename <- file.path(folder_path, "streams.txt")
  con <- file(filename, 'a')
  cat(stream, file = con, sep = "\n", append = T)
  close(con)
  
  str <- paste("\n[Added new stream: '", goal_name,": ", desc, "' through ", as.character(end),".]\n", sep = "")
  cat(str) 
  
} else if ("-seed" %in% args | "-se" %in% args) {
  # FIXME: If there's already a seed of that name, reject it.
  # TODO: g -seed list. List all seeds
  # TODO: g -se -edit. Open file for editing using system command.
  
  # Get seed name 
  if (length(args) <= 1) {
    cat("\nSeed name:") 
    seed_name <- readLines(file("stdin"), 1)
  } else {
    seed_name = args[2] 
    cat("\nSeed name:", seed_name, "\n") 
  }
  
  # Get description from user
  if (length(args) <= 2) {
    cat("Describe your seed (must be binary):")
    desc <- readLines(file("stdin"), 1)
    if (length(desc) == 0 ) stop("Please enter a description.")
    q()
  } else {
    # If the user supplies multiple arguments, the rest of the argmuents are the description  
    desc <- paste(args[3:length(args)], collapse = " ") 
  }
  
  # Save out to text: id |seed_name | description | planted | harvested_date | harvested
  seed <- c(NA, seed_name, desc, rep(NA, 3))
  names(seed) <- c("id", "seed", "desc", "planted", "harvest_date", "harvested")
  seed_filename <- file.path(seed_path, paste(field_day_date, "-seeds.txt", sep = ""))
  # con <- file(file_name, 'a')
  # cat(seed, file = con, sep = "\n", append = T)
  # close(con)
  
  # If the seed_filename exists, append to it
  if (file.exists(seed_filename)){
    df_seeds <- read.table(seed_filename, sep = "|", header = T)
    df_seeds <- rbind(df_seeds, seed)
  } else {
    df_seeds <- as.data.frame(t(seed))
  }
  # Save out 
  write.table(df_seeds, seed_filename, sep = "|", row.names = F)
  
  # Message user
  msg <- paste("\n[Added new seed: '", seed_name,": ", desc, 
               "' for field day ", as.character(field_day_date),".]\n", sep = "")
  cat(msg)
  

} else if (length(arg_ind_log) > 0) {
  # APPEND TO LOG --------------------------------------------
  # CONSIDER: I may want to prepend to the log file, so that it's easier to read? Not really necessary.
 
  # Pick the date depending on the log# (if it exists)
  test_fornum <- grep("-l[0-9]+|-log[0-9]+", args)
  if (length(test_fornum) > 0 ){
    logargs <- args[test_fornum]
    day_lag <- gsub("-l|-log", "", logargs) %>% as.numeric()
  } else {
    day_lag <- 0
  }
  log_date <- Sys.Date() - day_lag
  
  # Connect to log file
  filename <- file.path(folder_path, "log.txt")
  con <- file(filename, 'a')
  
  # Get every argument excep the log 
  to_log <- args[-arg_ind_log]
  
  # Save out to file
  for (a in to_log) {
    line <- paste(log_date, a, sep = "|")
    cat(line, file = con, sep = "\n", append = T)
  }
  close(con)
  
  msg <- paste("[Logs '", paste(to_log, collapse = ", "), "' added.]\n", sep = "")
  cat(msg)
  
} else if ("-p" %in% args){
  # PLANT SEEDS TODAY --------------------------
  # Add ability to track goals today
  # args <- c("-p", "1", "2", "4")
  # FIXME: every time you run this code, it overwrites your planted status
  
  to_track <- args[-which(args == "-p")] %>% as.numeric()
  # Read in seeds
  seed_filename <- list.files(seed_path, full.names = T) %>% tail(1)
  df_seeds <- read.table(seed_filename, sep = "|", header = T)
   
  # If to_track doesn't have any numbers just print out 
  if (length(to_track) == 0) {
    
    # Filter to unfinished seeds 
    today_seeds <- df_seeds %>% 
      filter(planted == Sys.Date(), harvested != 1) %>%
      select(seed, desc) %>% 
      mutate(type = "seed") %>%
      rename(name = seed)
    # Filter to unfinished streams
    today_streams <- df_streams %>% filter(thisday != 1) %>%
      select(stream, desc) %>% mutate(type = "stream") %>%
      rename(name = stream)
    
    today_out <- rbind(today_seeds, today_streams)
    cat("\n\nPending seeds and streams:")
    kable(today_out, align = "cccccccccc") %>% print()
    cat("\n\n")
    
  } else {
    
    # Plant the seeds  
    df_seeds$planted[to_track] <- as.character(Sys.Date())
    write.table(df_seeds, file = seed_filename, sep = "|", row.names = F) 
    
    msg <- paste("[Planted seeds '", 
                 paste(df_seeds$seed[to_track], collapse = ", "), 
                 "' today]", 
                 sep = "")
    cat(msg)
  }
 
  
} else {
  # PRINT STREAMS AND CURRENT SEEDS -----------------------------------------
  # Default: g <no options> 
  
  # Print current streams
  if (!("-d" %in% args)) {
    df_streams %<>% select(-desc, -start, -end, -total,-rate, -cnt, -possible)  
  }
  cat("\n\nCurrent streams ~~~~ and seeds ...\n")
  kable(df_streams, align = "cccccccccc") %>% print()
  
  # TRACK SEEDS --------------------------------------------------- 
  # Alternatively, you could read in the path using the field_day_date
  # FIXME: check to see if the seed exists
  seed_filename <- list.files(seed_path, full.names = T) %>% tail(1)
  df_seeds <- read.table(seed_filename, sep = "|", header = T)
  
  # Compare with log: read in log, filter to this week. Create Harvested and harvest date fields
  df_log_field <- df_log %>% 
    filter(date >= field_day_date) %>%
    rename(seed = finished, harvest_date = date) %>% 
    mutate(harvested = 1) 
  # Make unique. Prevents multiple seeds from merging. FIXME: don't allow seeds and streams to have the same name. read in the names to confirm before writing to file.
  df_log_field %<>% 
    group_by(seed) %>% 
    summarize(harvest_date = max(harvest_date), harvested = max(harvested))
  
  # Merge log onto seeds, to count "harvested". If harvested is already in the data, remove those columns
  if ("harvested" %in% names(df_seeds)) { df_seeds %<>% select(-harvested) }
  if ("harvest_date" %in% names(df_seeds)){ df_seeds %<>% select(-harvest_date)}
  # Create the harvested file
  df_seeds <- left_join(df_seeds, df_log_field, by = "seed") #%>%
    # select(-id) %>%
    # unique()
    
  
  # OUTPUT 
  df_seeds$harvested[is.na(df_seeds$harvested)] <- 0
  
  df_seeds %<>% arrange(harvested, desc(harvest_date)) %>%
    mutate(id = seq_along(seed)) %>% 
    select(id, everything())
   
  # Save out this file
  write.table(df_seeds, file = seed_filename, sep = "|", row.names = F)
 
  # print out 
  # Rename harvested to be the success rate
  tot_harv <- paste(sum(df_seeds$harvested), "/", nrow(df_seeds), sep = "")
  colnames(df_seeds) <- c("id", "seed", "desc", "planted", "harvested date", tot_harv)
  
  df_seeds %>% kable(align = "cccccc") %>% print()
  
  
}

cat("\n")

