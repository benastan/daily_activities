$(document).on('change', '#new_activity_record input[type="checkbox"]', function() {
  $(this).parents('form').submit();
});