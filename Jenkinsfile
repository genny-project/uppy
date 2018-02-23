pipeline {
	agent any
	stages {
    stage('Clone') {
      steps {
				cleanWs()
        checkout scm
      }
    }
		stage('Build') {
			steps {
				sh "./build-docker.sh ${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
			}
		}
		stage('Push') {
			steps {
				sh "docker push gennyproject/uppy:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
			}
		}
		stage('Done') {
			when { branch 'production' }
			steps {
				sh 'echo deploying'
			}
		}
	}
	post {
		success {
			withCredentials([string(credentialsId: 'e78cedc6-d1c0-4ff4-9fbb-fb65f7190c5d', variable: 'SLACK_WEBHOOK')]) {
				sh "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"gennyproject/uppy:${env.BRANCH_NAME}-${env.BUILD_NUMBER} successfully built! :goodstuff:\"}' ${SLACK_WEBHOOK}"
			}
		}
		failure {
			withCredentials([string(credentialsId: 'e78cedc6-d1c0-4ff4-9fbb-fb65f7190c5d', variable: 'SLACK_WEBHOOK')]) {
				sh "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"🚨🚨 gennyproject/uppy:${env.BRANCH_NAME}-${env.BUILD_NUMBER} failed to build/push! 🚨🚨\"}' ${SLACK_WEBHOOK}"
			}
		}
	}
}
