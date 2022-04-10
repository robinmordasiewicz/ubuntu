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
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container: `cat VERSION`" > VERSION.sha256'
        }
      }
    }
    stage('git status') {
      steps {
        script {
          sh '''
            git config user.email "robin@mordasiewicz.com"
            git config user.name "Robin Mordasiewicz"
            git diff --quiet && git diff --staged --quiet || echo "`cat VERSION`"
            git diff --quiet && git diff --staged --quiet || git commit -am "`cat VERSION`"
          '''
        }
      }
    }

    stage('Example') {
        steps {
            echo 'Hello World'

            script {
                def browsers = ['chrome', 'firefox']
                for (int i = 0; i < browsers.size(); ++i) {
                    echo "Testing the ${browsers[i]} browser"
                }
            }
        }
    }

    stage('Push Container') {
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
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null && skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` | jq ".Digest" > VERSION.sha256 || echo "create new container: `cat VERSION`" > VERSION.sha256'
        }
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
