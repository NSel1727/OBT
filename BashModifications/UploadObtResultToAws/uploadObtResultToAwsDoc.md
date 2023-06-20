## Removed Commented Code

Lines 11-12:
```
#SSH_TARGET="10.240.62.177"
#SSH_TARGET="10.240.62.57"  #OpenStack Region 5
```
              
Line 16:
```
#rsync -va -e "ssh -i ~/AWSSmoketest.pem"  ~/build/bin/OBT-*.txt ec2-user@ec2-3-133-112-185.us-east-2.compute.amazonaws.com:/home/ec2-user/OBT-009/.
```

Line 23:
```
#rsync -va -e "ssh -i ~/HPCC-Platform-Smoketest.pem"  ~/diskState.log  centos@ec2-35-183-5-250.ca-central-1.compute.amazonaws.com:/home/ec2-user/OBT-010/.
```

## Other Changes

Consistent Mulit-Word Variable Snake Case:

prevMonth -> PREV_MONTH
prevMonthYear -> PREV_MONTH_YEAR
prevMonthYearLong -> PREV_MONTH_YEAR_LONG
thisMonth -> THIS_MONTH
thisMonthYear -> THIS_MONTH_YEAR
thisMonthYearLong -> THIS_MONTH_YEAR_LONG
