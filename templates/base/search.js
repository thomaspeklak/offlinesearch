/*
 * $Author$
 * $Revision$
 * $LastChangedDate$
 */

$(document).ready(function(){
	$('#search').keydown(function(e){
		if(e.keyCode == 13){
			$('#search_results').show_results(this.value);
			return false;
		}
	})
});

(function($){
	$.fn.show_results = function(term){
		var foundTerms = new Array();
		var searchTerm=eval('/'+term+'/');
		for(t in terms)
			if (searchTerm.test(t)) foundTerms.push(t);
		var results=new Array();
		var foundDocsIds = new Array();
		for(t in foundTerms){
			for(docs in terms[foundTerms[t]]){
				var id = terms[foundTerms[t]][docs][0];
				var file = files[id];
				if (results[id])
					results[id][0]+=terms[foundTerms[t]][docs][1]*file[2];
				else
					results[id]=[terms[foundTerms[t]][docs][1]*file[2],file[1],file[0]];
			}
		}
		results.sort($.sortByFirstValue);
		output= new Array();
		while(r = results.shift())
			output.push('<li>'+r[0]+'<a href="'+r[1]+'">'+r[2]+'</a>');
		this.html('<ol>'+output.join('')+'</ol>');
	};
	$.get_matches = function (term) {
		
	};
	
	$.sortByFirstValue = function(a,b){return b[0]-a[0];};
	
})(jQuery);