# Route53 Dynamic Record Updater

The intent of this project is to emulate Dynamic DNS updaters (such as DynDNS), but to make it functional with Amazon's Route53 service in AWS. Specifically, it's designed to update every record in a hosted zone that are both "A" records and that match the IP of a previous run, but do not match a currently dynamically assigned address. In effect, the PS1 script can be set to run as a scheduled task to automatically get the external IP of the host it's running on, then check the target hosted zone and update IP's that should match but don't.

## Getting Started

Install the AWS Tools and SDK for .Net (includes PowerShell module)
Have an account and generate access keys for an account with permissions to modify resource record sets in Route53
Pull keys from AWS and store in a CSV file somewhere to be used by the script
Run/Modify AWS-Route53.ps1 from PowerShell with required parameters

### Prerequisites

PowerShell (v5.0)
[AWS Tools for Windows](http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi)

```
Give examples
```

### Installing

A step by step series of examples that tell you have to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc
