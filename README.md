## email-junk-catcher script

The best spam tool I've ever used allow-listed a set of domains. 

So, I execute this simple shell script via a `cron` job every few minutes to move messages I care about from my SPAM folder back into the Inbox based on the e-mailed from domain name.

#### Installation

Clone the repo and `cd` into the folder:

```shell
gh repo clone wassimk/email-junk-catcher
cd email-junk-catcher
```

Next, provide a way to get the email account connection details and login credentials. This `./server.sh` script should output a JSON hash with `username` and `password` attributes. Executing the script should return JSON.

```json
{
  "host": "secure.myemailserver.com",
  "username": "me@email.com",
  "password": "password",
  "port": 993,
  "ssl": true
}
```

Now, create the valid domains file with each line containing a domain that starts with an @, e.g., *@yahoo.com*.

```shell
touch valid-domains.conf
```

Next, open your user's `cron` table to schedule the job.

```shell
crontab -e
```

And here is the cron job.

```shell
*/2 * * * * /usr/bin/env ruby /Users/you/email-junk-catcher/email-junk-catcher.rb  >> /Users/you/email-junk-catcher/run.log 2>&1
```

#### Usage

Anytime you need an e-mail that goes to spam that you care about, add the domain to `valid-domains.conf`.

#### Log Rotation

One option for rotating the log files is [`logrotate`](https://github.com/logrotate/logrotate). Once installed, it's managed by creating a configuration file per set of logs needing rotation.

For example, install it via `brew install logrotate` and add an `email-junk-catcher` file to `/opt/homebrew/etc/logrotate.d/` with the following contents:

```
/Users/you/email-junk-catcher/logs/*.log
{
   daily
   rotate 30
   missingok
}
```
