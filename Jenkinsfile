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
      when { branch 'master'}
			steps {
				sh "./push.sh"
			}
		}
		stage('Done') {
			steps {
				sh 'echo Slacking'
			}
		}
	}
}
