pipeline {
  options {
    disableConcurrentBuilds()
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: ubuntu
            image: robinhoodis/ubuntu:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: IfNotPresent
            command:
            - /busybox/cat
            tty: true
            volumeMounts:
              - name: kaniko-secret
                mountPath: /kaniko/.docker
          restartPolicy: Never
          volumes:
            - name: kaniko-secret
              secret:
                secretName: regcred
                items:
                  - key: .dockerconfigjson
                    path: config.json
        '''
    }
  }
  stages {
    stage('Check repo to see if container is absent') {
      steps {
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container" > VERSION.sha256'
        }
      }
    }
    stage('Push Container') {
      //when { changeset "VERSION.sha256"}
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            /kaniko/executor --dockerfile=Dockerfile \
                             --context=git://github.com/robinmordasiewicz/ubuntu.git \
                             --destination=robinhoodis/ubuntu:`cat VERSION` \
                             --destination=robinhoodis/ubuntu:latest \
                             --cache=true
            '''
          }
        }
      }
    }
    stage('Get sha') {
      steps {
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container" > VERSION.sha256'
        }
      }
    }
    stage('git-commit') {
      steps {
        sh 'git config user.email "robin@mordasiewicz.com"'
        sh 'git config user.name "Robin Mordasiewicz"'
        sh 'git add -A'
        sh 'git diff --quiet && git diff --staged --quiet || git commit -am "New HTML: `date`"'
        withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
          sh 'git diff --quiet && git diff --staged --quiet || git push'
        }
      }
    }
  }
//  post {
//    always {
//      cleanWs(cleanWhenNotBuilt: false,
//            deleteDirs: true,
//            disableDeferredWipeout: true,
//            notFailBuild: true,
//            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
//                     [pattern: '.propsfile', type: 'EXCLUDE']])
//    }
//  }
}
