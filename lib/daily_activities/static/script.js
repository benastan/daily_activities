$(document).on('change', '#new_activity_record input[type="checkbox"]', function() {
  $(this).parents('form').submit();
});

$(document).find('[data-pie-chart]').each(function() {
  var context = this.getContext("2d");
  var data = $(this).data().pieChart;
  new Chart(context).Doughnut(data, { responsive: true, animation: false });
});
