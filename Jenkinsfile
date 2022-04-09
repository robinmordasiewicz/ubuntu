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
        sh 'git config user.email "robin@mordasiewicz.com"'
        sh 'git config user.name "Robin Mordasiewicz"'
        sh 'git add .'
        sh 'git commit -m "`cat VERSION`"'
          sh 'echo "--------------sha from after skopeo inspect-----------------------"'
          sh 'cat VERSION.sha256'
        }
      }
    }
    stage("Test changeset") {
        when {
            changeset "*"
        }
        steps {
            script {
                def changeLogSets = currentBuild.changeSets
                echo("changeSets=" + changeLogSets)
                for (int i = 0; i < changeLogSets.size(); i++) {
                    def entries = changeLogSets[i].items
                    for (int j = 0; j < entries.length; j++) {
                        def entry = entries[j]
                        echo "${entry.commitId} by ${entry.author} on ${new Date(entry.timestamp)}: ${entry.msg}"
                        def files = new ArrayList(entry.affectedFiles)
                        for (int k = 0; k < files.size(); k++) {
                            def file = files[k]
                            echo " ${file.editType.name} ${file.path}"
                        }
                    }
                }
            }
        }
    }
    stage('Hello') {
        steps {
            script {
                if (`git status --porcelain`) {
                    echo 'git status clean'
                }  else {
                    sh "echo 'git status changed"
                }
                }
        }
    }
    stage('git status') {
      steps {
        script {
          sh '''
            git status --porcelain
            git status
            echo 'Hello from main branch'
          '''
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
