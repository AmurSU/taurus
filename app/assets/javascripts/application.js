//= require jquery
//= require jquery_ujs
//= require active_scaffold
//= require record_select
//= require select2
//= require_self
//= require common
//= require_tree ./editors

jQuery(document).ready(function($) {

    $('.classroom_row').click(function() {
      window.open('/editor/classrooms/classrooms?classroom_id=' + $(this).attr('id'));
      return false;
    });

    $('#group_list_name').autocomplete({
        disabled: false,
        source: function(request, response) {
            $.getJSON('/editor/reference/groups.json', {
                group: request.term,
            },
            function(data) {
                var groups = new Array(0);
                $.each(data, function(index, i) {
                    groups.push({ label: i.group.descriptive_name, value: i.group.id });
                });
                response(groups);
            });
        },
        select: function(event, ui) {
            $.post('/editor/reference/groups_list/groups', {id : ui.item.value});
            $('#group_name').val('');
            return false;
        }
    });

    $('.group_list_remove').live('click', function() {
        var group_id = $(this).attr('group_id');
        $.post('/editor/reference/groups/' + group_id, {_method: 'delete'});
        $('#group_list_name').focus();
    });

    $('.button').button();

    // Карточки нагрузки у зав. кафедры
    function selectizePreferredClassrooms() {
        el = $("#record_preferred_classrooms_");
        if (el.size() && el.css('display') != "none")
            $("#record_preferred_classrooms_").select2({
                formatResult: formatResultedClassroomForSelect2,
                formatSelection: formatSelectedClassroomForSelect2
            });
    }

    $(document).on('as:action_success as:element_updated as:element_created', selectizePreferredClassrooms);
    selectizePreferredClassrooms();

    // Учебные планы у редакторов расписания

    // Поиск группы
    $("#teaching_plans_group_select").click( function () {
        var value = $("#teaching_plans_group_input").val();
        $("#teaching_plans_group_list tbody tr").each( function () {
            if ($("td:first-child", this).text().indexOf(value) < 0) {
                $(this).addClass("hidden");
            } else {
                $(this).removeClass("hidden");
            }
        });
    });
    $("#teaching_plans_group_reset").click( function () {
        $("#teaching_plans_group_input").val('');
        $("#teaching_plans_group_list tbody tr").removeClass("hidden");
    });

    $(".print_button").on('click', function () {
        window.print();
        return false;
    })

});
