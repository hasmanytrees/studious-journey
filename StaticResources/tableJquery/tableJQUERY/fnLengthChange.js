jQuery.fn.dataTableExt.oApi.fnLengthChange = function ( oSettings, iDisplay )
{
	oSettings._iDisplayLength = iDisplay;
    //oSettings.oApi._fnCalculateEnd( oSettings );

    /* If we have space to show extra rows (backing up from the end point - then do so */
    if ( oSettings._iDisplayEnd == oSettings.aiDisplay.length )
    {
        oSettings._iDisplayStart = oSettings._iDisplayEnd - oSettings._iDisplayLength;
        if ( oSettings._iDisplayStart < 0 )
        {
            oSettings._iDisplayStart = 0;
        }
    }

    if ( oSettings._iDisplayLength == -1 )
    {
        oSettings._iDisplayStart = 0;
    }
	
	if ( oSettings._iDisplayLength != -1 )
    {
        oSettings._iDisplayStart = 0;
    }
	
    oSettings.oApi._fnDraw( oSettings );

    if ( oSettings.aanFeatures.l )
    {
        $('select', oSettings.aanFeatures.l).val( iDisplay );
    }
};

jQuery.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          oSettings._iDisplayLength === -1 ?
            0 : Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
        "iTotalPages":    oSettings._iDisplayLength === -1 ?
            0 : Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
    };
};