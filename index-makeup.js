(function(){
  if (navigator.userAgentData.mobile) return;

  var sections = document.getElementsByTagName('section');
  var items = Array.prototype.slice.call(sections);
  
  items.sort(function(a, b){
      // TODO: Manage dates in a more careful manner
      var dateA = new Date(a.getElementsByClassName('date')[0].textContent);
      var dateB = new Date(b.getElementsByClassName('date')[0].textContent);
  
      if (dateA > dateB) return -1;
      if (dateA < dateB) return 1;
      
      return 0;
  });
  
  for(var item of items) {
      var parent = item.parentNode;
      var detatchedItem = parent.removeChild(item);
      parent.appendChild(detatchedItem);
  }
})()
