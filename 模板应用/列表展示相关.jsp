<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE jsp:include PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<jsp:include page="/public/public.jsp" />
		<style type="text/css">
		 	#selectDiv{
				padding:3px;
				float:left !important;
				height: auto !important;
				width: 100%;
			}
			.search-div{
				margin-left: 30px;
				height: 30px;
				margin-top:3px;
				float: left;
				width: 210px;
				*width: auto;
				*float: left !important;
				max-width: 300px;
			}
			
			#selectDiv div label{
				float: left;
			}
			
			#selectDiv div>input,#selectDiv div>select{
				float: right;
				width: 152px;
			}
			
			#selectDiv div.select{
				float: right;
				width: 152px;
			}
			
			#selectDiv div>select{
				width: 152px;
			}
		</style>
		
		<script type="text/javascript"> 
		/*
			一般一个完整的页面列表一般包含页面的展示，包括分页查询，
			过滤条件查询，过滤条件重置。特殊需求还包括像设置过滤条件项，
			显示列表项等。
		*/
			var weldingBomInstanceManage={};
			var $weldingBomInstanceGrid;
			var colAtter="";//当前列表属性名数据
			var treeCol="";//设置过后列表属性名数据
			var treeColumns=[];
			/*设置展示列表，
				由于datagrid中的columns：对应的列表格式如下
				[[
				{field:'',title:''},
				{field:'',title:''}
				]]
				因此renderColumns函数的功能是将查询到的列表结果封装成：
				colum = [
				{field:'',title:''},
				{field:'',title:''}
				]
				然后再：[colum]
			*/
			function renderColumns(columns_){
 				var _columns = [
					{field:'_checkbox','checkbox':true }
	 			];
				//columns_的结构为：[{atterName:"",ittleName:""},{atterName:"",ittleName:""}]
 	 			$.each(columns_,function(index,el){
 	 				if(el['atterName']=="partStatus"){
 	 					_columns.push({field:el['atterName'],title:el['titleName'],width:100, sortable:false,
							//1:正常；2:待删除；3:更新；
							formatter:function(value,dataRow,index){
								if(1==value){
									return "正常";
								}else if(2==value){
									return "待删除";
								}else if(3==value){
									return "更新";
							 	}
							}
						});
 	 				}else if(el['atterName']=="engineeringLevel"){
 	 					_columns.push({field:el['atterName'],title:el['titleName'],width:120,sortable:true,
 	 						formatter:function(value,dataRow){
								var str="";
								for(var i=0;i<parseInt(value);i++){
									str="&nbsp;"+str;
								}
								return str+value;
							}
 	 					});
 	 				}else if(el['atterName']=="id"){
 	 					_columns.push({field:el['atterName'],title:el['titleName'],width:100,hidden:true});
 	 				}else if(el['atterName']=="bopTrBiwUpLoadID"){
 	 					_columns.push({field:el['atterName'],title:el['titleName'],width:100, sortable:false,
							formatter:function(value,dataRow,index){
								if(0==value){
									return "未上件";
								}else{
									return "已上件";
								}
							}
						});
 	 				}else{
 	 					_columns.push({field:el['atterName'],title:el['titleName'],width:120,sortable:true});
 	 				}
 	 			});
 				return _columns;
 			}
			
	 		$(function(){
				/*
				 result：为从后台数据库中传过来的保存用户数值的显示列表的信息，result是一个map集合
				 key：columns存放了显示列表信息
				*/
	 			var columns_ = ${result.columns};//用户设置或默认的列表，
				/*Some.util.jsonObject() ???不是太理解:
					jsonObject:function(str){
						return (new Function("return " + str))();
					 },
				*/
	 			var columnsJs = Some.util.jsonObject('${result.columns}');
	 			for(var j=0;j<columnsJs.length;j++){
	 				colAtter=colAtter+columnsJs[j].atterName+",";//将当前的显示列表信息保存下来，用             //以当用户设置后的数据进行比较,如果没有发生变化，就不提交数据
	 			}
				columns = renderColumns(columns_);

				//easyui datagrid基础模板
	 			$weldingBomInstanceGrid=$("#weldingBomInstanceGrid").
					datagrid({
						striped:true, //显示斑马线效果，默认为false
						rownumbers:true,   //是否显示序号 
						nowrap:false,//表示可以换行，默认是true，指在一行中显示
						multiSort:true,//允许多列排序
						singleSelect:true,//只能选择一行
						selectOnCheck:false,//如果为false，选择行将不选中复选框。
						checkOnSelect:false,//选择行不能选中复选框
						remoteSort:false,//如果为true点击排序时回访问数据库排序
						fit:true,//面板大小适应父容器
						pagination:true, //底部显示分页栏工具
						pageSize:20, //每页显示数据数
						pageList:[20,50,100,150,200], //每页显示数列表
						toolbar:'#selectDiv',//顶部工具栏
						idField:'id',//一般要给一个id标识，防止出现一样的数据时无法定位该条数据问题
						url:'xxxxAction!xxxList.act',//请求url
						queryParams:{"bopTmDataSet.id":'${bopTmDataSet.id}'},//传参，多个参数以逗号分隔
						onLoadSuccess : function () {
							
						},
						rowStyler: function(index,row){
							
						},
						columns:[columns]//此种方法自由选择显示哪些列，并且可以排序。下面注释里的方法是固定显示的
					  /*[[//定义每个字段
							{field:'_checkbox',checkbox:true,hidden:false},//复选框，写法固定，与其//他字段显示稍有不同。
							{field:'id',title:"",width:100,hidden:true},//field：列字段名称，与传过//来的json中的key值保持一致；title：列标题，width：列宽，hidden：是否隐//藏，sortable：是否允许排序    具体的返回的json格式见附件1：“datagrid请//求的返回的json数据结构”
							{field:'partStatus',title:"状态",width:100, sortable:false,
								//1:正常；2:待删除；3:更新；
								//单元格formatter(格式化器)函数，最多带3个参数：
                                      //value：字段值,即对应的传过来的原始数据
                                      //row：dataRow。
                                      //index: 行索引。 
								formatter:function(value,dataRow,index){
									if(1==value){
										return "正常";//return指最终显示的数据
									}else if(2==value){
										return "待删除";
									}else if(3==value){
										return "更新";
									}
								},	
							},
							{field:'engineeringLevel',title:"工程等级",width:70,     hidden:false,sortable:false,
								//更改工程等级显示的样式，使其有层次感
								formatter:function(value,dataRow){
									var str="";
									for(var i=0;i<parseInt(value);i++){
										str="&nbsp;"+str;
									}
									return str+value;
								}
							},
							{field:'instanceNameZh',title:"零件中文名称",width:120, sortable:false }	
						]]*/
					});

				//即时模糊查询  combobox为easyui的下拉列表框
				//具体的json数据格式见附件2：“combobox请求的返回的json数据结构 ”
				$('#packageId').combobox({    
				    valueField:'id',  //数据名称,相当于数据id  
				    textField:'text',//显示名称，根据valueField和textField来解析返回的json数据
				    editable:true,
				    url: 'weldingBomInstanceAction!findByDataSetAndPackage.act?bopTmDataSet.id=${bopTmDataSet.id}',    

				});  
				
				//如果下拉列表已知且固定，可以数据data直接赋值
			  	$('#partSource').combobox({    
				    valueField:'id',    
				    textField:'text',
				    multiple:true,//可多选
					data: [{
						id: 'all',
						text: '全部',
						selected:true  //selected为默认选中项
					},{
						id: 'P',
						text: 'P'
					},{
						id: 'M',
						text: 'M'
					}],
					
					onSelect:function(record){//当多选时，
					//功能：点击全部，取消其他选项
					var val = $('#partSource').combobox('getValue');//获取选中的文本
					var val2 =$('#partSource').combobox('getText');
						if(val=="all" && val2.length>2){
							$('#partSource').combobox('unselect','all');
						}else{
							if(val2.length>=2 && val2.indexOf("全部")!=-1){
							$('#partSource').combobox('select','all');
								$('#partSource').combobox('unselect','P');
								$('#partSource').combobox('unselect','M');
							}
						}
					}
					
				}); 
				
				//零件类型
				$('#partType').combobox({    
				    multiple:true
				}); 
				
				//按键查询，13对应的是回车键
			  	var $searchDiv=$("#selectDiv");
	 			$searchDiv.keyEvent({
		 			keyCode:13,
		 			handler:function(event){
		 				weldingBomInstanceManage.method.search();
		 				event.preventDefault();//juery的这个事件方法可以防止跳转到该事件的默认方法中//去。
		 			}
	 			});
	 		});
	 		

	 		weldingBomInstanceManage.method={
 				//设置
 				setup:function(){
 					$('#columnSelectTree').tree({//查询所有列表，以tree的形式展示
 						url : "weldingBomInstanceAction!findTreeByUserId.act",
	 					checkbox:true,//每个节点前有复选框
	 				    queryParams:{"type":3},
	 				    dnd:true,//开启拖拽功能，可以排序
						/*
							在拖动一个节点之前触发，返回false可以拒绝拖动。
								target：释放的目标节点元素。
								source：开始拖动的源节点。
								point：表示哪一种拖动操作，可用值有：'append','top' 或 'bottom'。
						*/
	 				    onBeforeDrop:function(target, source, point){
	 					   if("append"==point){//append只当移动到目标本身时取消拖动
	 						   return false;
	 					   }
	 				   }
	 				});
 					
 					$('#columnSelectDialog').dialog({    
	 				    title: "<s:text name='property_hide_settings'/>",    
	 				    width:500,    
	 				    height: 400,    
	 				    cache: false,    
	 				    modal: true,//将窗体显示为模式化窗口。
	 				    resizable:true,//能够改变窗口大小。
	 				    buttons:[{
							text:"<s:text name='confirm'/>",
							iconCls:'icon-ok',
							handler:function(){
								treeColumns.length=0;
								treeIds="";//勾选的列表id
								var checked = $('#columnSelectTree').tree('getChecked');//获取列表勾
								$.each(checked,function(i,n){
	 								treeColumns.push({"atterConfigId":n.id,"atterName":n.atterName,"titleName":n.text,"sequence":i+1});//封装用户设置后的列表及其顺//序
	 								treeIds = treeIds+n.id+",";
	 								treeCol=treeCol+n.atterName+",";
	 							});

								if(treeCol==colAtter){
									treeIds="";
									treeCol="";
								}else{
									colAtter=treeCol;
									treeCol="";
								}
								var colJsons=[
								              {columns:treeIds,type:3}
								             ];
								
								if(treeIds.length>0){
									$.post("weldingBomInstanceAction!updateColumns.act",
										{columns:Some.util.toJson(colJsons)},function(result){
											$show("设置成功!");
										//列表部分
										columns.length = 0;
										columns = renderColumns(treeColumns);
										$weldingBomInstanceGrid.datagrid({    
											columns:[columns]
										});
										$('#columnSelectDialog').dialog("close");
		 							});
								}else{
									$('#columnSelectDialog').dialog("close");
								}
	 						}
						}]
					});
 				},

 				//提交查询条件
 		 		search:function(){
 					var searchJSON={};
 					searchJSON["selectPH"]=$("#selectPH").combobox('getValues');//多选
 					searchJSON["partNumber"]=$("#partNumber").val();//模糊查询
 					searchJSON["variateCondition"]=$("#variateCondition").val();//变量条件
 					searchJSON["upLoad"]=$("#upLoad").combobox('getValue');//多选
					$weldingBomInstanceGrid.datagrid("load",{"filterJsons":Some.util.toJson(searchJSON),"bopTmDataSet.id":'${bopTmDataSet.id}'}); 
					$weldingBomInstanceGrid.datagrid('clearChecked');
 				},
 				//重置
 				reset:function(){
 		 			$("#partType,#partSource,#partStatus,#upLoad").combobox("setValue","all");
					 $('#packageId').combobox("clear");
					 $('#selectPH').combobox("clear");
					$('#selectPH').combobox("reload"); 
					$("#partNumber,#instanceNameZh,#ffc,#shortSvpps,#typeId").val("");
					$weldingBomInstanceGrid.datagrid('clearChecked');
					$weldingBomInstanceGrid.datagrid("load",{"bopTmDataSet.id":'${bopTmDataSet.id}'});
 		 		}
 		 		
 		 	}
 		 	
	 		
		 </script>
	</head>
	
	<body class="easyui-layout">
	<%-- 用于显示设置弹出框 --%>
		<div id="columnSelectDialog">
			<div class="easyui-tabs" data-options="fit:true">
				<div title="列表设置" >
					<ul id="columnSelectTree"></ul> 
				</div>
			</div>   
		</div>

 		<div data-options="region:'center',split:true,title:' ',tools:'#tool_bar'" border="false">
 			<div  id="tool_bar">
				<a href="#" class="icon-down" onclick="weldingBomInstanceManage.method.importBom()"><s:property value="%{getText('import')}"/></a>
				<a href="#" class="icon-ok" onclick="weldingBomInstanceManage.method.comfirmUpdate()">确认更新</a>
				<a href="#" class="icon-hebing" onclick="weldingBomInstanceManage.method.upload()">上件</a>
				<a href="#" class="brick_go" onclick="weldingBomInstanceManage.method.swRegion()">焊点区域</a>
				<a href="#" class="brick_go" onclick="weldingBomInstanceManage.method.showStructure()">焊接结构</a>
				<a href="#" class="icon-setup" onclick="weldingBomInstanceManage.method.setup()"><s:text name='set_up'/></a>
			</div>
			<div id="weldingBomInstanceGrid"></div>
			<div id="selectDiv">
				<form id="seachForm" method="post">
					<div class="search-div">
						<label>
							<s:text name='PH过滤'/>
						</label>
						<div class="select">
							<select id="selectPH" class="easyui-combobox" name="selectPH" data-options="multiple:true,value:''">
							   	<s:iterator var="li" value='listPH'>
							   		<option value="${li.strSequence}"><s:property value="#li.partNumber"/>&nbsp<s:property value="#li.instanceNameZh"/></option>
							   	</s:iterator> 
							</select>  
						</div> 
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='part_number'/>
						</label>
						<input id="partNumber" class="easyui-validatebox search"  name="partNumber" />
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='part_name'/>
						</label>
						<input id="instanceNameZh" class="easyui-validatebox search"  name="instanceNameZh"/>
					</div> 
					
					<div class="search-div">
						<label>
							<s:text name='FFC'/>
						</label>
						<input id="ffc" class="easyui-validatebox search"  name="ffc" />
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='VPG'/>
						</label>
						<input id="shortSvpps" class="easyui-validatebox search"  name="shortSvpps" />
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='零件来源'/>
						</label>
						<div class="select">
							<select id="partSource"  name="partSource" ></select> 
						</div> 
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='零件类型'/>
						</label>
						<div class="select">
							<select id="partType" name="partType">
								<option value="all">全部</option>	   
							    <option value="DP">DP</option>   
							    <option value="SP">SP</option>   
							    <option value="SW">SW</option>   
							    <option value="PH">PH</option>   
							    <option value="MP">MP</option>   
							</select>
						</div> 
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='车型ID'/>
						</label>
						<div class="select">
							<input name="packageId" id="packageId"/>
						</div>
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='上件'/>
						</label>
						<div class="select">
							<select id="upLoad" class="easyui-combobox" name="upLoad">
								<option value="all">全部</option>	 
								<option value="1">已上件</option>	 
								<option value="2">未上件</option>	   
							</select> 
						</div> 
					</div>
					
					<div class="search-div">
						<label>
							<s:text name='状态'/>
						</label>
						<div class="select"> 
							<select id="partStatus" class="easyui-combobox" name="partStatus">
								<option value="all">全部</option>
								<option value="1">正常</option>	
								<option value="2">待删除</option>	
								<option value="3">更新</option>
								<option value="4">新增</option>
								<option value="5">替换</option>	
								<option value="6">被替换</option>
								<option value="7">删除</option>		
							</select> 
						</div>
					</div>

					<div class="search-div">
						<label>
							<s:text name='变量条件'/>
						</label>
						<input id="variateCondition" class="easyui-validatebox search"  name="variateCondition" />
					</div>
					
					<div class="search-div">
						<a href="#" class="easyui-linkbutton " data-options="iconCls:'icon-search', plain:true"   
						   onclick="weldingBomInstanceManage.method.search()">
						   <s:property value="%{getText('inquiry')}"/> <%--国际化--%>
						</a>
						<a href="#" class="easyui-linkbutton "  data-options="iconCls:'icon-reload', plain:true" 
						   onclick="weldingBomInstanceManage.method.reset()">
							<s:property value="%{getText('reset')}"/>
						</a>
					</div>
				</form>
			</div>
		</div>
	 </body>
</html>