-- Fleet Maintenance Work Orders
-- Demonstrates: Nested Table (collection), Record, and GOTO control flow

SET SERVEROUTPUT ON;

DECLARE
  ------------------------------------------------------------------
  -- 1) COLLECTION: Nested table to hold part costs (supports gaps)
  ------------------------------------------------------------------
  TYPE NumTable IS TABLE OF NUMBER;
  
  ------------------------------------------------------------------
  -- 2) RECORD: Work order record including a nested table
  ------------------------------------------------------------------
  TYPE WorkOrderRec IS RECORD (
    vehicle_id    NUMBER,
    plate_no      VARCHAR2(20),
    parts_costs   NumTable,      -- collection
    labor_hours   NUMBER,
    labor_rate    NUMBER,
    status        VARCHAR2(20)
  );

  -- Variables
  wo          WorkOrderRec;
  total_parts NUMBER := 0;
  grand_total NUMBER := 0;
  high_cost_threshold CONSTANT NUMBER := 3000; -- USD
  
  -- Utility to print indices that exist (demonstrates sparse collection handling)
  PROCEDURE print_existing_indices(p IN NumTable) IS
  BEGIN
    DBMS_OUTPUT.PUT('Parts (existing indices): ');
    IF p.COUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('None');
      RETURN;
    END IF;
    FOR i IN 1 .. NVL(p.LAST,0) LOOP
      IF p.EXISTS(i) THEN
        DBMS_OUTPUT.PUT(TO_CHAR(i));
        IF i < p.LAST THEN DBMS_OUTPUT.PUT(','); END IF;
      END IF;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
  END;
  
BEGIN
  ------------------------------------------------------------------
  -- Scenario A: Normal flow (valid data)
  ------------------------------------------------------------------
  wo.vehicle_id  := 101;
  wo.plate_no    := 'RAD-123Z';
  wo.parts_costs := NumTable(120, 250, 310, 420);  -- start dense
  wo.parts_costs.DELETE(2);                        -- create a gap (sparse)
  wo.labor_hours := 3.5;
  wo.labor_rate  := 45;
  wo.status      := 'NEW';

  -- Validate and sum parts
  total_parts := 0;
  FOR i IN 1 .. NVL(wo.parts_costs.LAST,0) LOOP
    IF wo.parts_costs.EXISTS(i) THEN
      IF wo.parts_costs(i) < 0 THEN
        GOTO InvalidData;
      END IF;
      total_parts := total_parts + wo.parts_costs(i);
    END IF;
  END LOOP;

  -- Compute grand total and branch if too high
  grand_total := total_parts + (wo.labor_hours * wo.labor_rate);
  IF grand_total > high_cost_threshold THEN
    GOTO HighCost;
  END IF;

  -- Normal printout
  DBMS_OUTPUT.PUT_LINE('Work Order for Plate: ' || wo.plate_no);
  print_existing_indices(wo.parts_costs);
  DBMS_OUTPUT.PUT_LINE('Total Parts Cost: ' || total_parts);
  DBMS_OUTPUT.PUT_LINE('Labor Hours: ' || wo.labor_hours);
  DBMS_OUTPUT.PUT_LINE('Labor Rate: ' || wo.labor_rate);
  DBMS_OUTPUT.PUT_LINE('Grand Total: ' || grand_total);
  wo.status := 'OK';
  DBMS_OUTPUT.PUT_LINE('Status: ' || wo.status);
  DBMS_OUTPUT.NEW_LINE;

  ------------------------------------------------------------------
  -- Scenario B: Invalid data (negative cost triggers GOTO InvalidData)
  ------------------------------------------------------------------
  wo.vehicle_id  := 102;
  wo.plate_no    := 'RAC-777G';
  wo.parts_costs := NumTable(100, -250, 80); -- negative value at index 2
  wo.labor_hours := 2;
  wo.labor_rate  := 50;
  wo.status      := 'NEW';

  total_parts := 0;
  FOR i IN 1 .. NVL(wo.parts_costs.LAST,0) LOOP
    IF wo.parts_costs.EXISTS(i) THEN
      IF wo.parts_costs(i) < 0 THEN
        -- Show which element was invalid then jump
        DBMS_OUTPUT.PUT_LINE('[ERROR] Invalid part cost encountered: ' || wo.parts_costs(i) || ' at index ' || i);
        GOTO InvalidData;
      END IF;
      total_parts := total_parts + wo.parts_costs(i);
    END IF;
  END LOOP;

  grand_total := total_parts + (wo.labor_hours * wo.labor_rate);
  IF grand_total > high_cost_threshold THEN
    GOTO HighCost;
  END IF;

  DBMS_OUTPUT.PUT_LINE('Work Order for Plate: ' || wo.plate_no);
  DBMS_OUTPUT.PUT_LINE('Grand Total: ' || grand_total);
  wo.status := 'OK';
  DBMS_OUTPUT.PUT_LINE('Status: ' || wo.status);
  DBMS_OUTPUT.NEW_LINE;

  ------------------------------------------------------------------
  -- Scenario C: High cost triggers GOTO HighCost
  ------------------------------------------------------------------
  wo.vehicle_id  := 103;
  wo.plate_no    := 'RAB-900K';
  wo.parts_costs := NumTable(2400, 1800, 700); -- very expensive
  wo.labor_hours := 4;
  wo.labor_rate  := 25;
  wo.status      := 'NEW';

  total_parts := 0;
  FOR i IN 1 .. NVL(wo.parts_costs.LAST,0) LOOP
    IF wo.parts_costs.EXISTS(i) THEN
      IF wo.parts_costs(i) < 0 THEN
        GOTO InvalidData;
      END IF;
      total_parts := total_parts + wo.parts_costs(i);
    END IF;
  END LOOP;

  grand_total := total_parts + (wo.labor_hours * wo.labor_rate);
  IF grand_total > high_cost_threshold THEN
    GOTO HighCost;
  END IF;

  DBMS_OUTPUT.PUT_LINE('Work Order for Plate: ' || wo.plate_no);
  DBMS_OUTPUT.PUT_LINE('Grand Total: ' || grand_total);
  wo.status := 'OK';
  DBMS_OUTPUT.PUT_LINE('Status: ' || wo.status);

  GOTO EndProgram;

  ------------------------------------------------------------------
  -- GOTO TARGETS
  ------------------------------------------------------------------
  <<InvalidData>>
  DBMS_OUTPUT.PUT_LINE('Work order flagged. Review required.');
  DBMS_OUTPUT.NEW_LINE;
  -- Continue instead of raising an exception to allow later scenarios
  -- (In production, you might RAISE or RETURN)

  <<HighCost>>
  DBMS_OUTPUT.PUT_LINE('[ALERT] High maintenance cost detected: ' || grand_total);
  DBMS_OUTPUT.PUT_LINE('Apply extra approvals before processing.');
  DBMS_OUTPUT.NEW_LINE;

  <<EndProgram>>
  DBMS_OUTPUT.PUT_LINE('Done.');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

