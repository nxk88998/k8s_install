#!/usr/bin/env bash

if [ $# -eq 1 ]; then
  zh=$1
else
  echo "请带上租户："
  exit
fi

ns=(
  dead_letter
  attendance
  manufacture_report
  plan
  equipment
  data_synchronism
  produce_process
  worker
  document
  upms
  serialcode
  exception
  mes_report
  file
  warehouse
  industrial
  auto
  collection
  device
  message_push
  netty
  energy
  admix_center
)

# 创建租户
echo "开始创建租户$zh"
if ! /pulsar/bin/pulsar-admin tenants list | grep -w $zh >/dev/null 2>&1; then
  /pulsar/bin/pulsar-admin tenants create $zh
fi
echo "创建租户$zh完成"
# 创建命名空间
for i in ${ns[*]}; do
  echo "开始创建命名空间${zh}/${i}"
  if ! /pulsar/bin/pulsar-admin namespaces list $zh | grep -w $i >/dev/null 2>&1; then
    echo "创建命名空间${zh}/${i}中"
    /pulsar/bin/pulsar-admin namespaces create $zh/$i
    /pulsar/bin/pulsar-admin namespaces set-retention $zh/$i  --size 10G --time 1d
  fi
  echo "创建命名空间${zh}/${i}完成"
done
