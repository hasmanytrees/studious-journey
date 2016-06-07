var pageInfo = 0;
        var recIdRef;
        
        function dispTable(){
        $(document).ready(function(){
            
            
            var i=0;
            $("[id$='Add']").each(function() {
                
                $(this).attr('name',  i);
                i++;
            });
            
            $(".datePicker").css("z-index","76787877678");   // to display date on the top layer on pop up
             
            // for jquery table plugin
            
            oTable =  $("[id$='TableList']").dataTable({
                //"bJQueryUI": true,
                "sPaginationType": "full_numbers",
                "sPageLast":"last",
                "iDisplayLength": 10  
            });
            $("[id$='header']").css("cursor","pointer");
            oTable.fnPageChange(pageInfo);
             
        });
        
        }
        
        function showTable(){
            var i=0;
            $("[id$='Add']").each(function() {
                
                $(this).attr('name',  i);
                i++;
            });
            $(".datePicker").css("z-index","76787877678");   // to display date on the top layer on pop up
            
            // for jquery table plugin
            
            oTable =  $("[id$='TableList']").dataTable({
                //"bJQueryUI": true,
                "sPaginationType": "full_numbers",
                "sPageLast":"last",
                "iDisplayLength": 10,
                //"lengthMenu": [[10, 25, 50, -1], [100]],
            });
            $("[id$='header']").css("cursor","pointer");
            oTable.fnPageChange(pageInfo);
            document.getElementById('j_id0:MassCreateImpact:j_id9:TableList:selectCheck').checked = false;
        }
        
        function tableHandler()
        {
            
            // for getting table propely after rerender
            
            oTable =  $("[id$='TableList']").dataTable({
                //"bJQueryUI": true,
                "sPaginationType": "full_numbers",
                "sPageLast":"last",
                "iDisplayLength": 10    
            });
            // alert($(".dataTables_paginate paging_full_numbers").len);
            $(".dataTables_length").eq(0).remove();
            $(".dataTables_filter").eq(0).remove();
            $(".dataTables_info").eq(1).remove();
            $(".dataTables_paginate.paging_full_numbers").eq(1).remove();
            $("[id$='header']").css("cursor","pointer");
            
            $("[id$='header']").css("cursor","pointer");
        }
        
        function addAll(){
            var table =  $("[id$='TableList']").dataTable();
            pageInfo = table.fnPagingInfo().iPage;
            table.fnFilter('');
            table.fnLengthChange(500);
        }
        
        function selectAllCheck(){
           var inputElem = document.getElementById('j_id0:MassCreateImpact:j_id9:TableList:selectCheck').checked;
            var table =  $("[id$='TableList']").dataTable();
            if(inputElem == true){        
                $("[id$='checkSelectBen']", table.fnGetNodes()).attr('checked',true);
                return false;
            }
            if(inputElem == false){       
                $("[id$='checkSelectBen']", table.fnGetNodes()).attr('checked',false);
                return false;
            }
        }