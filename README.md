# How do I know the number of photos processed?

Redirect the stdout to a log file:

````bash
./s3_photos_syncing.rb > s3_photos_syncing.log
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
  } ' ./s3_photos_syncing.log"
````
