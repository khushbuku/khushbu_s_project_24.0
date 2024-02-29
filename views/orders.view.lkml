# The name of this view in Looker is "Orders"
view: orders {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: demo_db.orders ;;
  drill_fields: [id]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year,hour]
    sql: ${TABLE}.created_at ;;
  }

  dimension: date_formatted {
    sql: ${created_date} ;;
    html:{{ rendered_value | date: "%b %Y" }};;

  }

  dimension: dater {
    type: duration_month
    sql: ${created_month} ;;
    html:{{ rendered_value | date: "%b %Y" }};;

  }

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Status" in Explore.

  parameter: dynamic_created_date_selection {
    type: string
    allowed_value: {value: "Created Month"}
    allowed_value: {value: "Created Date"}
    allowed_value: {value: "Created Hour"}
  }

  dimension: dynamic_created_date_dimension {
    type: string
    label_from_parameter: dynamic_created_date_selection
    sql:
    {% if dynamic_created_date_selection._parameter_value == "'Created Month'" %} ${created_month}
    {% elsif dynamic_created_date_selection._parameter_value == "'Created Hour'" %} ${created_hour}
    {% else %} ${created_date} {% endif %}

      ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: old {
    sql: "CANCELLED"  ;;
}
dimension: new {
  sql: "PENDING" ;;
}

dimension: ml_version_filter {
  type: string
  suggest_dimension: status
  sql:
  CASE WHEN ${status} = "CANCELLED" THEN ${old}
  ELSE ${new}
  END ;;
}

  parameter: number_of_results {
    type: number
    allowed_value: {
      label: "Less than 500"
      value: "< 500"
    }
    allowed_value: {
      label: "Less than 10,000"
      value: "< 10000"
    }
    allowed_value: {
      label: "All Results"
      value: "> 0"
    }
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  users.id,
  users.first_name,
  users.last_name,
  billion_orders.count,
  fakeorders.count,
  hundred_million_orders.count,
  hundred_million_orders_wide.count,
  order_items.count,
  order_items_vijaya.count,
  ten_million_orders.count
  ]
  }

}
