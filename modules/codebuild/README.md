
##CODEBUILD

The infraestructure is ready to install a codebuild to launch a buildpsec file 

Actually we are using this infraestructure to analize the code quality from github repositories.


### Variables


- buildspec =./buildspec.yml : The repository path and file name in the github where buildpec file is located.
- image=  "968479493337.dkr.ecr.eu-west-1.amazonaws.com/esdataecr:latest" : The ecr image - with the docker we want to use for this codebuild
- sonardns="sonar-data.example.com": The url where sonar is listening
- sonarproject = sonarprojectname: Sonar project name for this repository
- githubproject = githubprojectname: Github project name
- Resourcename = The name of the resource from main
- country = es: Country name 
- team= "devops|dev|data": The Team name
- subnet_id = private subnet id for codebuild vpc 
- service = service from main
- vpc_id=Vpc: id where subnet is located
- secret_id : Secret Manager Arn with github credentials

### requirements
It is important to know that for each execution, the buidspec file must be located in the github repository we are going to analyce

Build spec example 
```
version: 0.2
#env:
 # variables:
     # key: "value"
  #parameter-store:
     # key: "value"
     # key: "value"
  #secrets-manager:
     # key: secret-id:json-key:version-stage:version-id
     # key: secret-id:json-key:version-stage:version-id
  #exported-variables:
     # - variable
     # - variable
  #git-credential-helper: yes
#batch:
  #fast-fail: true
  #build-list:
  #build-matrix:
  #build-graph:
phases:
  install:
   
    #If you use the Ubuntu standard image 2.0 or later, you must specify runtime-versions.
    #If you specify runtime-versions and use an image other than Ubuntu standard image 2.0, the build fails.
    #runtime-versions:
      # name: version
      # name: version
     commands:
        - yum install R jq -y
      # - command
  #pre_build:
    #commands:
      # - command
      # - command
  build:
    commands:
        - cd /codebuild/output/*/src/github.com/$githubproject
        - cd /sonar-r-plugin/sample-project/R
        - find /codebuild/output/*/src/github.com/$githubproject -name *.R|grep .R |xargs -I{} cp "{}" .
        - cd ..
        - rm lintr_out.json
        - Rscript run_lintr.R
        - ls -lrt 
    ## - command
      # - command
  post_build:
    commands:
      # - command
      # - command
      - sonar-scanner -Dsonar.projectKey=test -Dsonar.sources=. -Dsonar.host.url=http://$sonardns:9000  > logtemporal
      - testok=`cat logtemporal |grep "More about the report processing at"|cut -d " " -f8` 
      - echo "SALIDATEST"
      - echo $testok
      - salidaok=`curl "http://$sonardns:9000/api/qualitygates/project_status?projectKey=$sonarproject"|jq ".projectStatus.status"  -r`
      - echo "SALIDAOK"
      - echo $salidaok
      - if [ $salidaok = "OK" ]; then exit 0;else exit 1;fi
#reports:
  #report-name-or-arn:
    #files:
      # - location
      # - location
    #base-directory: location
    #discard-paths: yes
    #file-format: JunitXml | CucumberJson
#artifacts:
  #files:
    # - location
    # - location
  #name: $(date +%Y-%m-%d)
  #discard-paths: yes
  #base-directory: location
#cache:
  #paths:
    # - paths
```
### Features

- Support different kind of docker ecr for several teams or requirements
- It is allowed external sonanr url but the internal servers are  strongly advised
