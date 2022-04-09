pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
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
    stage('INIT') {
      steps {
        cleanWs()
        checkout scm
        echo "Building ${env.JOB_NAME}..."
      }
    }
    stage('Check repo to see if container is absent') {
      steps {
        container('ubuntu') {
          sh 'echo "--------------sha from git repo-----------------------"'
          sh 'cat VERSION.sha256'
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container: `cat VERSION`" > VERSION.sha256'
          sh 'echo "--------------sha from after skopeo inspect-----------------------"'
          sh 'cat VERSION.sha256'
        }
      }
    }
    stage('git status') {
      steps {
        script {
          sh '''
            git diff --quiet && git diff --staged --quiet || echo "Committing changes `cat VERSION"
            git diff --quiet && git diff --staged --quiet || git commit -am "Ubuntu Container: `cat VERSION`"
          '''
        }
      }
    }
    stage('Hello') {
        steps {
            script {
                if (1) {
                    sh "echo 'git status same"
                }  else {
                    sh "echo 'git status changed"
                }
                }
        }
    }
    stage('Push Container') {
      when { changeset "VERSION"}
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
      when { changeset "VERSION"}
      steps {
          sh 'echo "--------------before getting latest sha-----------------------"'
          sh 'cat VERSION.sha256'
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container: `cat VERSION`" > VERSION.sha256'
        }
          sh 'echo "--------------after getting latest sha-----------------------"'
          sh 'cat VERSION.sha256'
      }
    }
    stage('git-commit') {
      when { changeset "VERSION.sha256"}
      steps {
        sh 'git config user.email "robin@mordasiewicz.com"'
        sh 'git config user.name "Robin Mordasiewicz"'
        sh 'git add .'
        // sh 'git diff --quiet && git diff --staged --quiet || git commit -am "New Container HASH: `cat VERSION`"'
        sh 'git commit -m "`cat VERSION`"'
        withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
          // sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
          // sh 'git push origin main'
          sh 'git push origin HEAD:main'
        }
      }
    }
  }
  post {
    always {
      cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
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
