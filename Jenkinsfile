pipeline {
    parameters {
        gitParameter branchFilter: '*origin/(.\*)*', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
    }
    environment{
        //项目名称
        PROJECT_NAME = "angular-empty-project"

        //git仓库地址
        PROJECT_GIT_URL = "https://gitlab.com/KonChoo/angular-empty-project.git"

        //git凭证
        GIT_CREDENTIALS=""
        //镜像tag
        IMAGE_TAG = "latest"

        //docker文件
        DOCKERFILE = "Dockerfile"

        //dev环境k8s部署环境
        K8S_DEV_DEPLOYMENT_FILE = "deployment.yaml"
    }
    agent any
    stages {
        stage('从Git仓库拉取代码') {
            steps {
                script {
                    println "当前环境变量 : "
                    sh 'env'
                    println "当前目录位置 : "
                    sh 'pwd'
                    println "当前目录位置所有文件 : "
                    sh 'ls'
                    cleanWs()
                    if(env.GIT_CREDENTIALS == null || env.GIT_CREDENTIALS.trim().isEmpty()){                     
                        git branch: "${params.BRANCH}", 
                        url: "${PROJECT_GIT_URL}"
                    }else{
                        git branch: "${params.BRANCH}", 
                        url: "${PROJECT_GIT_URL}",
                        credentialsId: "${GIT_CREDENTIALS}"
                    }
                }
            }
        }
        stage('构建项目的Docker镜像') {
            steps {
                script {
                        if (env.ENVIRONMENT == 'dev') {
                                //${JOB_NAME} should be the same as git repo project name
                                sh "docker build -t 192.168.0.111:8050/${PROJECT_NAME}:${IMAGE_TAG} -f ${DOCKERFILE} ."
                                sh "docker push 192.168.0.111:8050/${PROJECT_NAME}:${IMAGE_TAG}"
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
                                def yaml = readFile("${K8S_DEV_DEPLOYMENT_FILE}")
                                yaml = yaml.replace('${IMAGE}', "192.168.0.111:8050/${PROJECT_NAME}:${IMAGE_TAG}")
                                println("当前项目的k8s配置文件内容 : \n")
                                println("${yaml}")
                                writeFile file: "deployment.yaml", text: yaml
                                withCredentials([file(credentialsId: "k8s-credentials", variable: 'KUBECONFIG_FILE')]) {
                                    sh "kubectl --kubeconfig=${KUBECONFIG_FILE} apply -f ${K8S_DEV_DEPLOYMENT_FILE}"
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
