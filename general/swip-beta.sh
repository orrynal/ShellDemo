#!/bin/bash


: <<COMMITBLOCK
# 脚本名称：swip.sh 
# 脚本用途：数字转换IP地址脚本
# 作者：orrynal
# 版本：VER. 1.0
# Copyright (c) 2015-2018 
# 修改日期：2015/10/19


COMMITBLOCK

# 默认值
DEFAULT=0

# 初始值
initData=$1

# 将输入数字分为两段
# 整数部分
_src_int=`echo $initData|awk -F. '{printf("%d\n",$1)}'|sed -e 's/\ //g'`

# 为负数，退出
if [ "$_src_int" -lt "0" ] 
then
	echo -e "\e[1;31m 输入数值不能为负数！\e[0m"
	exit 0
fi

# 小数部分，%s确保无小数时值为空
# if [ ! -z `echo $1|awk -F. '{printf("%s",$2)}'` ] 

# 条件判断值,判断小数部分数值：
# $_arg=0  输入数字为正整数
# $_arg=1  输入数字带有小数
_arg=`echo $initData|awk -F. '{printf("%d",$2)}'`
# echo "_arg IS $_arg"

# 无值时%d的结果为0
# if [ `echo $1|awk -F. '{printf("%d",$2)}'` -ne 0 ] 
if [ "$_arg" -ne "0" ] 
then
	# 原数字带小数时
	_src_dec=`echo $initData|awk -F. '{printf("0.%s\n",$NF)}'|sed -e 's/\ //g'`
	# echo "带小数：$_src_dec"
else
	# 原数字不带小数时
	# %s打印为空值
	# _src_dec=`echo $1|awk -F. '{printf("%s\n",$2)}'|sed -e 's/\ //g'`
	
	# %d打印值为0
	_src_dec=`echo $initData|awk -F. '{printf("%d\n",$2)}'|sed -e 's/\ //g'`

	# echo "原数字不带小数"
fi



# 小数扩大10倍
_src_dec_enlg10=`echo $_src_dec\*10|bc`
# echo "_src_dec_enlg10 = $_src_dec_enlg10"


# 取扩大后整数部分
# %s打印字符，%d打印数字
# _src_dec_enlg10_intval=`echo $_src_dec_enlg10|awk -F. '{printf("%s\n",$1)}'`
_src_dec_enlg10_intval=`echo $_src_dec_enlg10|awk -F. '{printf("%d\n",$1)}'`
# echo "_src_dec_enlg10_intval = $_src_dec_enlg10_intval"


# 小数部分有效数字值
# _src_dec_valid_decval=`echo $1|awk -F. '{printf("%s\n",$2)}'|sed -e 's/\ //g'`
_src_dec_valid_decval=`echo $initData|awk -F. '{printf("%d\n",$NF)}'|sed -e 's/\ //g'`

# 设置10进制字面值等于8进制数字面值；如数值为1.0123（10），取小数点后值0123，使0123（10)=(0123)(8)
let "_oct2dec = 0$_src_dec_valid_decval"

# 设置10进制字面值等于16进制字面值
# let "_oct2dec = 0x$_src_dec_valid_decval"

# 小数部分有效值如果为0
if [ "$_src_dec_valid_decval" -eq "0" ]
then
	_src_dec_valid_decval="无"
fi

# echo "输入数字为：		$1"
# echo "整数部分为：		$_src_int"
# echo "小数部分为：		$_src_dec"
# echo "小数部分有效数字值为：	$_src_dec_valid_decval"
# echo


# 取参数值，并转换为整数
# _midsrc=`echo $1|awk -F. '{printf("%d\n",$NF)}'|sed -e 's/\ //g'`

# echo -e "\e[1;31m 原始数据为：$1 \e[0m"
# echo -e "\e[1;34m 小数部分取整数为：$_src_dec_valid_decval \e[0m"
# echo

# 8进制转10进制
# _oct2dec=`echo $((8#$_src_dec_valid_decval))`
# _oct2dec=`echo "obase=8;$_src_dec_valid_decval"|bc`

# 再将小数转换为10进制的数字转换为16进制，不能用_oct2dec=`echo $((16#$_oct2dec))`
# echo "obase=16;$_oct2dec"|bc

# 8进制转16进制
if [ "$_src_dec_enlg10_intval" -lt  "1" ]
then
	# 0.0x时转换
	_oct2hex=`echo "obase=16;$_oct2dec"|bc`
	# echo -e "\e[1;32m 原小数部分（0.0x）转化为十进制为：\e[0m"
	# echo -e  "\e[1;32m $_src_dec_valid_decval (8) = $_oct2dec (16) \e[0m"
else
	# 0.x时不转换
	_oct2hex=`echo "obase=16;$_src_dec_valid_decval"|bc`
	# echo "不需要按8进制转换"
	# echo -e "\e[1;31m 原小数部分（0.x）转化为十六进制为：\e[0m"
	# echo -e  "\e[1;31m $_src_dec_valid_decval (10) = $_oct2hex (16) \e[0m"
fi


# _midtemp0=`echo $_oct2dec`
# echo "转化为十进制数为：$_midtemp0"

# 调试
# echo int is $1
# echo hex is $_int2hex
# echo hex length is $_len

usage() {
	echo
	echo "**************************************************************************"
	echo "*                                                                        *"
	echo "*  "用法: ./`basename $0` 正整数或正小数"                                *"
	echo "*                                                                        *"
	echo "*  "说明: 小数部分小于0.1时，小数部分不能含有8、9两个数字，否则转换报错" *"
	echo "*                                                                        *"
	echo "*  "示例   ./`basename $0` 123.345"                                      *"
	echo "*                                                                        *"
	echo "**************************************************************************"
	echo
}

info() {
	# 判断参数
	echo "_arg IS $_arg"

	echo "输入数字为：		$initData"
	# 如果_src_int没设置或为空，那么就以DEFAULT作为其值
	echo "整数部分为：		${_src_int:-DEFAULT}"
	echo "小数部分为：		$_src_dec"
	echo "小数部分有效数字值为：	$_src_dec_valid_decval"
	echo
	echo -e "\e[1;31m 原始数据为：$initData \e[0m"
	echo -e "\e[1;34m 小数部分取整数为：$_src_dec_valid_decval \e[0m"
	echo
	
	# 小数部分扩大10倍后，整数部分取值
	if [ "$_src_dec_enlg10_intval" -lt  "1" ]
	then
		# 0.0x时转换
		echo -e "\e[1;32m 原小数部分（0.0x）转化为十进制为：\e[0m"
		echo -e  "\e[1;32m $_src_dec_valid_decval (8) = $_oct2dec (16) \e[0m"
	else
		# 0.x时不转换
		echo "不需要按8进制转换"
		echo -e "\e[1;31m 原小数部分（0.x）转化为十六进制为：\e[0m"
		echo -e  "\e[1;31m $_src_dec_valid_decval (10) = $_oct2hex (16) \e[0m"
	fi

	# 是否是小数
	echo "带小数：$_src_dec"

	# 扩大10倍
	echo "扩大10倍：_src_dec_enlg10 = $_src_dec_enlg10"

	# 扩大后整数部分
	echo "扩大后整数部分：_src_dec_enlg10_intval = $_src_dec_enlg10_intval"
}

# 初始化参数
init() {
	# 设置转换函数初始值
	# if [ `echo $1|awk -F. '{printf("%d",$2)}'` -ne 0 ]
	if [ "$_arg" -ne "0" ]
	then
		# 为小数时
		
		# awk 参数
		_awkscript='{printf "%06s\n",$0}'
		
		# 16进制数值长度
		_len=6
		
		# 循环次数
		_loo=` expr $_len / 2`
		
		# 转换参数
		_switch=$_oct2hex
		
		# 转换后长度
		_swed_len=`expr length $_switch`
		echo "_swed_len = $_swed_len" 
	
	else
		# 为整数时
		
		# 10进制数转16进制数
		_int2hex=`echo "obase=16;$initData"|bc`
		
		# awk 参数
		_awkscript='{printf "%08s\n",$0}'

		# 16进制数值长度
		_len=8
		
		# 循环次数
		_loo=` expr $_len / 2`
		
		# 转换参数
		_switch=$_int2hex

		# 转换后长度
		_swed_len=`expr length $_switch`
		echo "_swed_len = $_swed_len" 

	fi
}

# 初始化
init

# 转换函数
switchip() {
    # 判断16进制数长度，小于8位时，左边加0
	if [ "$_swed_len" -le "$_len" ]
	then
		# 获取16进制数值，不足8（6），左边补零
        _temp=`echo $_switch|awk "$_awkscript"`

		# 设置长度为8位
		_len_eight=`expr length $_temp`
		# echo -e "_len_eight = $_len_eight \n"

		# echo _temp$_len $_temp

	else
		# 大于8（6），从右向左截取8（6）位
        _temp=`echo ${_switch:(-$_len)}`
		_len_eight=`echo $_swed_len`
        # echo "_len_eight = $_len_eight"
        # echo _temp$_len $_temp
	fi

	# 分段获得16进制数值，如1F2B3380，那么分4段为：1F 2B 33 80，并将之转换为10进制
	for ((i=0,n=0;i<$_loo;i++))
	do
		# echo "n的初始值为：$n"
		
		# 将分段数值存入_array数组
		_array[i]=`echo ${_temp:$n:2}`

		# 将数组中的值存入_varray数组
		_varray=`echo ${_array[$i]}`

		# 转换为10进制数存入_ips数组
	        _ips[i]=`echo $((16#${_varray}))`

		#将数组值存入_vips数组
       		 _vips=`echo ${_ips[$i]}`

		#显示数值
	        # echo _array[$i] = $_varray
	        # echo _ips[$i] =  $_vips

		# n为截取字符值，上面_array[i]=`echo ${_temp:$n:2}`中
       		 ((n+=2))

       		 # 打印最终结果
		if [ "$n" -ge "$_len_eight" -a "$_len" -gt "6" ]
		then
			echo -e "\e[1;31m IP地址为：`echo ${_ips[*]}|sed -e 's/\ /\./g'` \e[0m"
		else
			echo -e "\e[1;31m IP地址为：$_src_int.`echo ${_ips[*]}|sed -e 's/\ /\./g'` \e[0m"
		fi

		# ((n+=2))
		# echo "n循环值为：$n"
	done    
}


#小数转ip
dectoip() {
	echo "小数部分转IP"

	# 整数部分大于0吗？
	# if [ `echo $1|awk -F. '{printf("%d",$2)}'` -ne 0 ] 

	if [ "$_arg" -ne "0" ] 
	then
		# 整数部分大于0
		echo "整数部分大于0"
		
		# 整数部分大于255吗
		if [ "$_src_int" -gt "255" ]
		then
			# 大于255
			echo "小数前的整数值不能大于256" 
			exit 0
		else
			# 这个整数值即为ip中第一字段值，因为小于255，所以不需要转换
			# echo "第一字段值为：$_src_int"
			switchip
		fi	
	else
		# 整数部分等于0，再判断小数点后0的个数
		echo "整数部分等于0，再判断小数点后0的个数"
		
		# 小数长度（不包括整数部分）
		# b=`echo $a|awk -F. '{printf("%s\n",$2)}'|wc -l`
		
		# 小数部分乘10>=1，那么小数点后直接接有效数字。

		if [ "$_src_dec_enlg10_intval" -ge "1" ]
		then 	
			echo "0.x"
			# 小数点后一个0的情况
			echo "小数点后一个0的情况"
			switchip
		else 
			echo "0.0x"
			# 小数放大10倍
			xx=`echo $c\*10|bc`

			# 小数点后多个0的情况
			echo "小数点后多个0的情况"

		fi
	fi
}

# 参数判断
if [ "$#" -lt "1" -o "$initData" = "-h" -o "$initData" = "--help" -o "$initData" = "?"]
then
	usage
else
	info
fi

# 判断是整数还是小数
if [ ! -z `echo $initData|awk -F. '{printf("%s",$2)}'` ]
then 
	# 是小数
	echo $initData  is a decimal
	dectoip	
else 
	# 是整数
	echo $initData is a integer
	switchip
fi
