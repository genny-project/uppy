pipeline {
	agent any
	options {
    skipDefaultCheckout true
	}
	stages {
    stage('Clean') {
      steps {
        deleteDir()
        checkout scm
      }
    }
		stage('Build') {
			steps {
				sh "./build-docker.sh ${env.BRANCH_NAME}-latest"
			}
		}
		stage('Push') {
			steps {
				sh "docker push gennyproject/uppy:${env.BRANCH_NAME}"
			}
		}
		stage('Done') {
			steps {
				sh 'echo Slacking'
			}
		}
	}
}
