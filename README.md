## email-junk-catcher script

The best spam tool I've ever used just allow-listed a set of domains. 

So, I execute this simple shell script via a `cron` job every few minutes to move messages I care about from my SPAM folder back into the Inbox based on the e-mailed from domain name.

#### Installation

Clone the repo and `cd` into the folder:
```shell
gh repo clone wassimk/email-junk-catcher
cd email-junk-catcher
```

Next, provide a way to get the email account login credentials. This `./login.sh` script should output a JSON hash with `username` and `password` attributes.

`````shell
$ ./login.sh
{ username: 'me@email.com', password: 'pass' }
`````

Next, open your user's `cron` table to schedule the job.

```
crontab -e
```

And here is the cron job.

```shell
*/2 * * * * /usr/bin/env ruby /Users/you/email-junk-catcher/email-junk-catcher.rb  >> /Users/you/email-junk-catcher/run.log 2>&1
```

#### Consider Rotating the Logs

The log file will get big. Consider doing something about it.
