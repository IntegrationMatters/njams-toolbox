# nJAMS toolbox
This repository contains tools that can help you with the daily use of nJAMS. Let us know if you have any issues using them, there is always space for improvement. Feel free to fork.

* findDomainObjects.ps1

  Find domain objects of given nJAMS instance. Assume you have a big nJAMS instance containing hundreds of domain objects and you want to find the domain objects that match a specific configuration. For example, you may want to find domain objects with an incorrect retention setting, or domain objects that have accidentally turned on StripOnSuccess. This script will easily find these domain objects.

* setLogLevel.ps1

  Set log level for domain objects with regards to a given domain object path of an nJAMS instance. Assume you want to change the log level for several domain objects and you do not want to change each domain object one by one in nJAMS UI. This script will help you to change the log level for domain objects of a specific path and and its sub elements.