CREATE SCHEMA IF NOT EXISTS open_data;

CREATE OR REPLACE VIEW open_data.tmcs_joined AS (
  SELECT
    tcm.*,
    tcd.time_start,
    tcd.time_end,
    tcd.sb_cars_r,
    tcd.sb_cars_t,
    tcd.sb_cars_l,
    tcd.nb_cars_r,
    tcd.nb_cars_t,
    tcd.nb_cars_l,
    tcd.wb_cars_r,
    tcd.wb_cars_t,
    tcd.wb_cars_l,
    tcd.eb_cars_r,
    tcd.eb_cars_t,
    tcd.eb_cars_l,
    tcd.sb_truck_r,
    tcd.sb_truck_t,
    tcd.sb_truck_l,
    tcd.nb_truck_r,
    tcd.nb_truck_t,
    tcd.nb_truck_l,
    tcd.wb_truck_r,
    tcd.wb_truck_t,
    tcd.wb_truck_l,
    tcd.eb_truck_r,
    tcd.eb_truck_t,
    tcd.eb_truck_l,
    tcd.sb_bus_r,
    tcd.sb_bus_t,
    tcd.sb_bus_l,
    tcd.nb_bus_r,
    tcd.nb_bus_t,
    tcd.nb_bus_l,
    tcd.wb_bus_r,
    tcd.wb_bus_t,
    tcd.wb_bus_l,
    tcd.eb_bus_r,
    tcd.eb_bus_t,
    tcd.eb_bus_l,
    tcd.nx_peds,
    tcd.sx_peds,
    tcd.ex_peds,
    tcd.wx_peds,
    tcd.nx_bike,
    tcd.sx_bike,
    tcd.ex_bike,
    tcd.wx_bike,
    tcd.nx_other,
    tcd.sx_other,
    tcd.ex_other,
    tcd.wx_other
  FROM open_data.tmcs_count_metadata tcm
  JOIN open_data.tmcs_count_data tcd USING (count_id)
  ORDER BY tcd.count_id ASC, tcd.time_start ASC
);
