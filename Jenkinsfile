pipeline {
    agent any
    stages {
        stage('从Git仓库拉取代码') {
            steps {
                script {
                        cleanWs()
                        git branch: 'master', url: 'https://gitlab.com/KonChoo/angular-empty-project.git'
                    
                }
            }
        }
        stage('构建项目的Docker镜像') {
            steps {
                script {
                        sh 'env'
                        sh 'pwd'
                        sh 'ls'
                        if (env.ENVIRONMENT == 'dev') {
                                sh "gradle build -b ${module}/build.gradle -x test"
                                //${JOB_NAME} should be the same as git repo project name
                                sh "docker build -t 192.168.0.111:8050/${JOB_NAME}:${BUILD_ID} -f Dockerfile ."
                                sh "docker push 192.168.0.111:8050/${JOB_NAME}:${BUILD_ID}"
                        } else {
                                println "当前选择的环境待实现..."
                                currentBuild.result = "FAILURE"
                                return
                        }
                }
            }
        }
        stage('部署项目到K8s集群') {
            steps {
                script {
                            if (env.ENVIRONMENT == "dev") {
                                def yaml = readFile("deployment.yaml")
                                yaml = yaml.replace('${IMAGE}', "192.168.0.111:8050/${JOB_NAME}:${BUILD_ID}")
                                println("当前项目的k8s配置文件内容 : \n")
                                println("${yaml}")
                                writeFile file: "deployment.yaml", text: yaml
                                withCredentials([file(credentialsId: "k8s-credentials", variable: 'KUBECONFIG_FILE')]) {
                                    sh "kubectl --kubeconfig=${KUBECONFIG_FILE} apply -f deployment.yaml"
                                }
                            } else {
                                println "当前选择的环境待实现..."
                                currentBuild.result = "FAILURE"
                                return
                            }
                }
            }
        }
    }
}
