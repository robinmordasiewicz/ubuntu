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
      when { changeset "VERSION"}
      steps {
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null || echo "create new container: `cat VERSION`" > BUILDNEWCONTAINER.txt'
        }
      }
    }
    stage('Build/Push Container') {
      when { changeset "VERSION"}
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            [ -f BUILDNEWCONTAINER.txt ] && \
            /kaniko/executor --dockerfile=Dockerfile \
                             --context=git://github.com/robinmordasiewicz/ubuntu.git \
                             --destination=robinhoodis/ubuntu:`cat VERSION` \
                             --destination=robinhoodis/ubuntu:latest \
                             --cache=true || \
            exit 0
            '''
          }
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
}
