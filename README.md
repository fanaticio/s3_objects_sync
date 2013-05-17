[![Build Status](https://travis-ci.org/fanaticio/s3_objects_sync.png?branch=develop)](https://travis-ci.org/fanaticio/s3_objects_sync)
[![Coverage Status](https://coveralls.io/repos/fanaticio/s3_objects_sync/badge.png?branch=develop)](https://coveralls.io/r/fanaticio/s3_objects_sync)
[![Code Climate](https://codeclimate.com/github/fanaticio/s3_objects_sync.png)](https://codeclimate.com/github/fanaticio/s3_objects_sync)

# Installation steps

* bundle
* cp s3_objects_sync.yml{.sample,}
* edit the s3_objects_sync.yml
* run the script

# How do I know the number of objects processed?

Redirect the stdout to a log file:

````bash
./s3_objects_sync.rb > s3_objects_sync.log
````

and, in another shell, you can run the following command:

````bash
watch -n1 "awk '
  BEGIN { info=0; error=0; already_copied=0; copied=0 }
  /- copied/       { copied +=1 }
  /already copied/ { already_copied +=1 }
  /- info -/       { info +=1 }
  /- error -/      { error +=1 }
  END {
    total_copied = already_copied + copied;
    print \"copied: \"copied\" --  already copied: \"already_copied\" --  total copied: \"total_copied\" --  error: \"error;
  } ' ./s3_objects_sync.log"
````
