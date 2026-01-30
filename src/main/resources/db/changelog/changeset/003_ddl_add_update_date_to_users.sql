--liquibase formatted sql
--changeset kamagin:add_update_date_column

ALTER TABLE users
    ADD COLUMN update_date DATE;

--rollback ALTER TABLE users DROP COLUMN update_date;