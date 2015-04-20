$(document).on('change', '#new_activity_record input[type="checkbox"]', function() {
  $(this).parents('form').submit();
});

$(document).find('[data-pie-chart]').each(function() {
  var context = this.getContext("2d");
  var data = $(this).data().pieChart;
  new Chart(context).Doughnut(data, {
    responsive: true,
    animation: false
  });
});

$(document).find('[data-bar-chart]').each(function() {
  var context = this.getContext("2d");
  var data = $(this).data().barChart;
  new Chart(context).Bar(data, {
    responsive: true,
    legendTemplate: "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>",
    animation: false
  });
});
