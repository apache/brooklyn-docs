/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

node(label: 'ubuntu') {
    catchError {
        def environmentDockerImage

        def dockerTag = env.BUILD_TAG.replace('%2F', '-')
        def buildArgs = '';

        if (env.CHANGE_ID == null) {
            buildArgs = '--install';
        }

        withEnv(["DOCKER_TAG=${dockerTag}", "BUILD_ARGS=${buildArgs}"]) {
            stage('Clone repository') {
                checkout scm
            }

            stage('Prepare environment') {
                echo 'Building docker image for build environment ...'
                environmentDockerImage = docker.build('brooklyn:${DOCKER_TAG}')
            }

            // Conditional stage to checkout website on SVN and setup BROOKLYN_SITE_DIR, when not building a PR
            if (env.CHANGE_ID == null) {
                stage('Clone Brooklyn website') {
                    sh 'svn --non-interactive --trust-server-cert co https://svn.apache.org/repos/asf/brooklyn/site brooklyn-site-public'
                    sh 'cd brooklyn-site-public'
                    sh 'svn up'
                    sh 'ls style/img/apache-brooklyn-logo-244px-wide.png || { echo "ERROR: checkout is wrong" ; exit 1 ; }'
                    sh 'export BROOKLYN_SITE_DIR=`pwd`'
                }
            }

            stage('Build website') {
                environmentDockerImage.inside('-i --name brooklyn-${DOCKER_TAG} -v ${PWD}:/usr/workspace') {
                    sh './_build/build.sh website-root ${BUILD_ARGS}'
                }
            }

            // Conditional stage to deploy artifacts, when not building a PR
            if (env.CHANGE_ID == null) {
                stage('Sanity check') {
                    input "Does the build look ok?"
                }

                stage('Deploy website') {
                    sh 'cd ${BROOKLYN_SITE_DIR-./brooklyn-site-public}'
                    sh 'svn add * --force'
                    sh 'export DELETIONS=$( svn status | sed -e "/^!/!d" -e "s/^!//" )'
                    sh 'if [ ! -z "${DELETIONS}" ] ; then svn rm ${DELETIONS} ; fi'
                    sh 'svn ci -m "Update Brooklyn website from ${BRANCH_NAME}, built by ${BUILD_TAG} (${BUILD_URL})"'
                }
            }

            // TODO: Publish docker image to https://hub.docker.com/r/apache/brooklyn/ ?
        }
    }

    // Conditional stage, when not building a PR
    if (env.CHANGE_ID == null) {
        stage('Send notifications') {
            // Send email notifications
            step([
                $class: 'Mailer',
                notifyEveryUnstableBuild: true,
                recipients: 'dev@brooklyn.apache.org',
                sendToIndividuals: false
            ])
        }
    }
}
