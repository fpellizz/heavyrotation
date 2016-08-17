# heavyrotation
A shell script to have a nice logrotate on your custom application.


It reads some parameter from a info file and use them to move logs file into a custom backup dir.
logrotate cannot write on a different filesystem so this script does it.

I need to backup, compress and move the log files of a web application 
