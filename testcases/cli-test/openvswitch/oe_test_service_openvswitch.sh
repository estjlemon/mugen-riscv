#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2021/04/28
# @License   :   Mulan PSL v2
# @Desc      :   Test openvswitch.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL openvswitch
    service=openvswitch.service
    log_time=$(date '+%Y-%m-%d %T')
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    service "${service}" restart
    CHECK_RESULT $? 0 0 "${service} restart failed"
    service "${service}" stop
    CHECK_RESULT $? 0 0 "${service} stop failed"
    service "${service}" start
    CHECK_RESULT $? 0 0 "${service} start failed"
    SLEEP_WAIT 3
    service "${service}" status | grep "Active" | grep "active (exited)"
    CHECK_RESULT $? 0 0 "${service} start failed"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    service "${service}" start
    service "${service}" reload
    CHECK_RESULT $? 0 0 "${service} reload failed"
    service "${service}" status | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    service "${service}" stop
    DNF_REMOVE
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
