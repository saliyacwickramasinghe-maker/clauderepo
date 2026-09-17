{
  title: "Fleetio",

  # Replace the connection hash below with generated code from CoPilot before testing in Test code!
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API key',
        control_type: 'password',
        optional: false,
        hint: 'Create and retrieve your API key at secure.fleetio.com/api_keys'
      },
      {
        name: 'account_token',
        label: 'Account Token',
        optional: false,
        hint: 'Retrieve your account token from secure.fleetio.com/api_keys'
      }
    ],

    authorization: {
      type: 'api_key',

      apply: lambda do |connection|
        headers(
          "Authorization": "Token #{connection['api_key']}",
          "Account-Token": connection['account_token'],
          "X-Api-Version": "2025-05-05",
          'Content-Type' => 'application/json'
        )
      end
    },

    base_uri: lambda do |connection|
      'https://secure.fleetio.com/api'
    end
  },

  test: lambda do
    get("https://secure.fleetio.com/api/profile/me")
  end,

  triggers: {
    fleetio_webhook: {
      title: 'Fleetio webhook',

      subtitle: 'Trigger on selected Fleetio webhook events',

      description: lambda do |_input, _picklist_label|
        'Triggers when selected Fleetio webhook events occur'
      end,

      help: 'Creates a Fleetio webhook subscription for the selected events.',

      input_fields: lambda do
        [
          {
            name: 'events',
            label: 'Events to listen for',
            delimeter: ',',
            optional: false,
            control_type: 'multiselect',
            pick_list: 'fleetio_webhook_events',
            hint: 'Select one or more Fleetio events'
          }
        ]
      end,

      webhook_subscribe: lambda do |webhook_url, connection, input, _recipe_id|
        events_payload =
          parse_json(input['events']).each_with_object({}) do |event_name, hash|
            hash[event_name] = true
          end


        payload = events_payload.merge(
          'enabled' => true,
          'description' => 'Workato connection trigger',
          'url' => webhook_url
        )

        post('https://secure.fleetio.com/api/webhooks')
          .headers(
            "Authorization": "Token #{connection['api_key']}",
            "Account-Token": connection['account_token'],
            "X-Api-Version": "2025-05-05",
            'Content-Type' => 'application/json'
          )
          .payload(payload)
      end,

      webhook_unsubscribe: lambda do |webhook, connection|
        delete("https://secure.fleetio.com/api/webhooks/#{webhook['id']}")
          .headers(
            "Authorization": "Token #{connection['api_key']}",
            "Account-Token": connection['account_token'],
            "X-Api-Version": "2025-05-05",
            'Content-Type' => 'application/json'
          )
      end,

      webhook_notification: lambda do |_input, payload, _headers, _params|
        payload
      end,

      dedup: lambda do |payload|
        payload['id']
      end,

      output_fields: lambda do |_object_definitions|
        [
          {
            name: 'event',
            type: 'string'
          },
          {
            name: 'payload',
            type: 'object',
            properties: [
              { name: 'id' }
            ],
            of: 'object'
          }
        ]
      end,

      sample_output: lambda do
        {
          id: 12345,
          event: 'part_created',
          payload: {
            id: 12345
          }
        }
      end
    }
  },

  actions: {
    Contacts__Create: {
      title: "Create Contact",
      hint: "Create Contact in Fleetio Developer API",
      subtitle: "Create Contact in Fleetio Developer API",
      help: "Creates a new contact.",
      input_fields: lambda do |object_definitions|
        object_definitions['Contacts__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Contact_v2']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Contacts__Create_execute, connection, input, extended_input_schema)
      end
    },
    Contacts__Index: {
      title: "List Contacts",
      hint: "List Contacts in Fleetio Developer API",
      subtitle: "List Contacts in Fleetio Developer API",
      help: "Returns a list of contacts excluding archived.",
      input_fields: lambda do |object_definitions|
        object_definitions['Contacts__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Contacts__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Contacts__Index_execute, connection, input, extended_input_schema)
      end
    },
    Contacts__Show: {
      title: "Retrieve Contact",
      hint: "Retrieve Contact in Fleetio Developer API",
      subtitle: "Retrieve Contact in Fleetio Developer API",
      help: "Retrieves the details of an existing contact.",
      input_fields: lambda do |object_definitions|
        object_definitions['Contacts__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Contact_v2']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Contacts__Show_execute, connection, input, extended_input_schema)
      end
    },
    Contacts__Update: {
      title: "Update Contact.",
      hint: "Update Contact. in Fleetio Developer API",
      subtitle: "Update Contact. in Fleetio Developer API",
      help: "Updates a contact.",
      input_fields: lambda do |object_definitions|
        object_definitions['Contacts__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Contact_v2']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Contacts__Update_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Assignments__Create: {
      title: "Create Assignment",
      hint: "Create Assignment in Fleetio Developer API",
      subtitle: "Create Assignment in Fleetio Developer API",
      help: "Create an Equipment Assignment",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Assignments__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        []
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Assignments__Create_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Assignments__Index: {
      title: "Retrieve Assignment",
      hint: "Retrieve Assignment in Fleetio Developer API",
      subtitle: "Retrieve Assignment in Fleetio Developer API",
      help: "List Equipment Assignments",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Assignments__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Equipment__Assignments__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Assignments__Index_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Assignments__Unassign: {
      title: "Unassign Assignment",
      hint: "Unassign Assignment in Fleetio Developer API",
      subtitle: "Unassign Assignment in Fleetio Developer API",
      help: "Unassign an Equipment Assignment",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Assignments__Unassign_input']
      end,
      output_fields: lambda do |object_definitions|
        []
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Assignments__Unassign_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Create: {
      title: "Create Equipment",
      hint: "Create Equipment in Fleetio Developer API",
      subtitle: "Create Equipment in Fleetio Developer API",
      help: "Creates a new Equipment",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Equipment_Created']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Create_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Index: {
      title: "List Equipment",
      hint: "List Equipment in Fleetio Developer API",
      subtitle: "List Equipment in Fleetio Developer API",
      help: "Returns a list of your Equipment. Defaults to only returning non-archived Equipment, but you can include archived Equipment in the results as well.",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Equipment__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Index_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Show: {
      title: "Retrieve Equipment",
      hint: "Retrieve Equipment in Fleetio Developer API",
      subtitle: "Retrieve Equipment in Fleetio Developer API",
      help: "Retrieve the details of an existing Equipment.",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Equipment']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Show_execute, connection, input, extended_input_schema)
      end
    },
    Equipment__Update: {
      title: "Update Equipment",
      hint: "Update Equipment in Fleetio Developer API",
      subtitle: "Update Equipment in Fleetio Developer API",
      help: "Update a Equipment",
      input_fields: lambda do |object_definitions|
        object_definitions['Equipment__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Equipment']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Equipment__Update_execute, connection, input, extended_input_schema)
      end
    },
    FuelEntries__Create: {
      title: "Create Fuel Entry",
      hint: "Create Fuel Entry in Fleetio Developer API",
      subtitle: "Create Fuel Entry in Fleetio Developer API",
      help: "Creates a new Fuel Entry.",
      input_fields: lambda do |object_definitions|
        object_definitions['FuelEntries__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['FuelEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:FuelEntries__Create_execute, connection, input, extended_input_schema)
      end
    },
    FuelEntries__Index: {
      title: "List Fuel Entries",
      hint: "List Fuel Entries in Fleetio Developer API",
      subtitle: "List Fuel Entries in Fleetio Developer API",
      help: "Returns a list of Fuel Entries belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['FuelEntries__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['FuelEntries__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:FuelEntries__Index_execute, connection, input, extended_input_schema)
      end
    },
    FuelEntries__Show: {
      title: "Retrieve Fuel Entry",
      hint: "Retrieve Fuel Entry in Fleetio Developer API",
      subtitle: "Retrieve Fuel Entry in Fleetio Developer API",
      help: "Retrieve the details of an existing Fuel Entry.",
      input_fields: lambda do |object_definitions|
        object_definitions['FuelEntries__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['FuelEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:FuelEntries__Show_execute, connection, input, extended_input_schema)
      end
    },
    FuelEntries__Update: {
      title: "Update Fuel Entry",
      hint: "Update Fuel Entry in Fleetio Developer API",
      subtitle: "Update Fuel Entry in Fleetio Developer API",
      help: "Update a Fuel Entry",
      input_fields: lambda do |object_definitions|
        object_definitions['FuelEntries__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['FuelEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:FuelEntries__Update_execute, connection, input, extended_input_schema)
      end
    },
    InventoryJournalEntries__Create: {
      title: "Create Inventory Journal Entry",
      hint: "Create Inventory Journal Entry in Fleetio Developer API",
      subtitle: "Create Inventory Journal Entry in Fleetio Developer API",
      help: "This endpoint provides the ability to adjust parts inventory.",
      input_fields: lambda do |object_definitions|
        object_definitions['InventoryJournalEntries__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['InventoryJournalEntry_Created']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:InventoryJournalEntries__Create_execute, connection, input, extended_input_schema)
      end
    },
    InventoryJournalEntries__Show: {
      title: "Retrieve Inventory Journal Entry",
      hint: "Retrieve Inventory Journal Entry in Fleetio Developer API",
      subtitle: "Retrieve Inventory Journal Entry in Fleetio Developer API",
      help: "Retrieve the details of an existing Journal Entry.",
      input_fields: lambda do |object_definitions|
        object_definitions['InventoryJournalEntries__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['InventoryJournalEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:InventoryJournalEntries__Show_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Create: {
      title: "Create Issue",
      hint: "Create Issue in Fleetio Developer API",
      subtitle: "Create Issue in Fleetio Developer API",
      help: "Creates a new Issue.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Create_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Index: {
      title: "List Issues",
      hint: "List Issues in Fleetio Developer API",
      subtitle: "List Issues in Fleetio Developer API",
      help: "Returns a list of Issues belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issues__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Index_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Show: {
      title: "Retrieve Issue",
      hint: "Retrieve Issue in Fleetio Developer API",
      subtitle: "Retrieve Issue in Fleetio Developer API",
      help: "Retrieve the details of an existing Issue.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Show_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Update: {
      title: "Update Issue",
      hint: "Update Issue in Fleetio Developer API",
      subtitle: "Update Issue in Fleetio Developer API",
      help: "Update an Issue",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Update_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Close: {
      title: "Close Issue",
      hint: "Close Issue in Fleetio Developer API",
      subtitle: "Close Issue in Fleetio Developer API",
      help: "Closes an Issue. The Issue must be in a state that can transition to Closed status.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Close_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Close_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Resolve: {
      title: "Resolve Issue",
      hint: "Resolve Issue in Fleetio Developer API",
      subtitle: "Resolve Issue in Fleetio Developer API",
      help: "Resolves an Issue. The Issue must be in a state that can transition to Resolved status.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Resolve_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Resolve_execute, connection, input, extended_input_schema)
      end
    },
    Issues__Reopen: {
      title: "Reopen Issue",
      hint: "Reopen Issue in Fleetio Developer API",
      subtitle: "Reopen Issue in Fleetio Developer API",
      help: "Reopens an Issue. The Issue must be in a state that can transition to Open status.",
      input_fields: lambda do |object_definitions|
        object_definitions['Issues__Reopen_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Issue']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Issues__Reopen_execute, connection, input, extended_input_schema)
      end
    },
    Parts__Create: {
      title: "Create Part",
      hint: "Create Part in Fleetio Developer API",
      subtitle: "Create Part in Fleetio Developer API",
      help: "Creates a new Part",
      input_fields: lambda do |object_definitions|
        object_definitions['Parts__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Part_Created']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Parts__Create_execute, connection, input, extended_input_schema)
      end
    },
    Parts__Index: {
      title: "List Parts",
      hint: "List Parts in Fleetio Developer API",
      subtitle: "List Parts in Fleetio Developer API",
      help: "Returns a list of Parts belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['Parts__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Parts__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Parts__Index_execute, connection, input, extended_input_schema)
      end
    },
    Parts__Update: {
      title: "Update Part",
      hint: "Update Part in Fleetio Developer API",
      subtitle: "Update Part in Fleetio Developer API",
      help: "Update a Part",
      input_fields: lambda do |object_definitions|
        object_definitions['Parts__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Part']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Parts__Update_execute, connection, input, extended_input_schema)
      end
    },
    PurchaseOrders__Create: {
      title: "Create Purchase Orders",
      hint: "Create Purchase Orders in Fleetio Developer API",
      subtitle: "Create Purchase Orders in Fleetio Developer API",
      help: "Creates a new Purchase Order",
      input_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrders__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrder_Created']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:PurchaseOrders__Create_execute, connection, input, extended_input_schema)
      end
    },
    PurchaseOrders__Index: {
      title: "List Purchase Orders",
      hint: "List Purchase Orders in Fleetio Developer API",
      subtitle: "List Purchase Orders in Fleetio Developer API",
      help: "Returns a list of Purchase Orders belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrders__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrders__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:PurchaseOrders__Index_execute, connection, input, extended_input_schema)
      end
    },
    PurchaseOrders__Show: {
      title: "Retrieve Purchase Order",
      hint: "Retrieve Purchase Order in Fleetio Developer API",
      subtitle: "Retrieve Purchase Order in Fleetio Developer API",
      help: "Retrieve the details of an existing Purchase Order.",
      input_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrders__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrder']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:PurchaseOrders__Show_execute, connection, input, extended_input_schema)
      end
    },
    PurchaseOrders__Update: {
      title: "Update Purchase Order",
      hint: "Update Purchase Order in Fleetio Developer API",
      subtitle: "Update Purchase Order in Fleetio Developer API",
      help: "Update a Purchase Order",
      input_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrders__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['PurchaseOrder']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:PurchaseOrders__Update_execute, connection, input, extended_input_schema)
      end
    },
    ServiceEntries__Create: {
      title: "Create Service Entry",
      hint: "Create Service Entry in Fleetio Developer API",
      subtitle: "Create Service Entry in Fleetio Developer API",
      help: "Creates a new Service Entry",
      input_fields: lambda do |object_definitions|
        object_definitions['ServiceEntries__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['ServiceEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:ServiceEntries__Create_execute, connection, input, extended_input_schema)
      end
    },
    ServiceEntries__Index: {
      title: "List Service Entries",
      hint: "List Service Entries in Fleetio Developer API",
      subtitle: "List Service Entries in Fleetio Developer API",
      help: "Returns a list of Service Entries belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['ServiceEntries__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['ServiceEntries__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:ServiceEntries__Index_execute, connection, input, extended_input_schema)
      end
    },
    ServiceEntries__Show: {
      title: "Retrieve Service Entry",
      hint: "Retrieve Service Entry in Fleetio Developer API",
      subtitle: "Retrieve Service Entry in Fleetio Developer API",
      help: "Retrieve the details of an existing Service Entry.",
      input_fields: lambda do |object_definitions|
        object_definitions['ServiceEntries__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['ServiceEntry']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:ServiceEntries__Show_execute, connection, input, extended_input_schema)
      end
    },
    ServiceEntries__Update: {
      title: "Update Service Entry",
      hint: "Update Service Entry in Fleetio Developer API",
      subtitle: "Update Service Entry in Fleetio Developer API",
      help: "Update a Service Entry",
      input_fields: lambda do |object_definitions|
        object_definitions['ServiceEntries__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        []
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:ServiceEntries__Update_execute, connection, input, extended_input_schema)
      end
    },
    VehicleAssignments__Create: {
      title: "Create Vehicle Assignment",
      hint: "Create Vehicle Assignment in Fleetio Developer API",
      subtitle: "Create Vehicle Assignment in Fleetio Developer API",
      help: "Creates a new Vehicle Assignment.",
      input_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignments__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignment']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:VehicleAssignments__Create_execute, connection, input, extended_input_schema)
      end
    },
    VehicleAssignments__Index: {
      title: "List Vehicle Assignments",
      hint: "List Vehicle Assignments in Fleetio Developer API",
      subtitle: "List Vehicle Assignments in Fleetio Developer API",
      help: "Returns a list of vehicle assignments.",
      input_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignments__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignments__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:VehicleAssignments__Index_execute, connection, input, extended_input_schema)
      end
    },
    VehicleAssignments__Show: {
      title: "Retrieve Vehicle Assignment",
      hint: "Retrieve Vehicle Assignment in Fleetio Developer API",
      subtitle: "Retrieve Vehicle Assignment in Fleetio Developer API",
      help: "Retrieve the details of an existing Vehicle Assignment.",
      input_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignments__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignment']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:VehicleAssignments__Show_execute, connection, input, extended_input_schema)
      end
    },
    VehicleAssignments__Unassign: {
      title: "Unassign Vehicle Assignment",
      hint: "Unassign Vehicle Assignment in Fleetio Developer API",
      subtitle: "Unassign Vehicle Assignment in Fleetio Developer API",
      help: "Immediately End a Vehicle Assignment",
      input_fields: lambda do |object_definitions|
        object_definitions['VehicleAssignments__Unassign_input']
      end,
      output_fields: lambda do |object_definitions|
        []
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:VehicleAssignments__Unassign_execute, connection, input, extended_input_schema)
      end
    },
    Vehicles__Create: {
      title: "Create Vehicle",
      hint: "Create Vehicle in Fleetio Developer API",
      subtitle: "Create Vehicle in Fleetio Developer API",
      help: "Creates a new vehicle. If you need to create many vehicles at once, use the Bulk API to avoid Rate Limiting errors.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vehicles__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleTwo']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vehicles__Create_execute, connection, input, extended_input_schema)
      end
    },
    Vehicles__Index: {
      title: "List Vehicles",
      hint: "List Vehicles in Fleetio Developer API",
      subtitle: "List Vehicles in Fleetio Developer API",
      help: "Returns a list of vehicles excluding archived.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vehicles__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Vehicles__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vehicles__Index_execute, connection, input, extended_input_schema)
      end
    },
    Vehicles__Show: {
      title: "Retrieve Vehicle",
      hint: "Retrieve Vehicle in Fleetio Developer API",
      subtitle: "Retrieve Vehicle in Fleetio Developer API",
      help: "Retrieve the details of an existing Vehicle.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vehicles__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleTwo']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vehicles__Show_execute, connection, input, extended_input_schema)
      end
    },
    Vehicles__Update: {
      title: "Update Vehicle",
      hint: "Update Vehicle in Fleetio Developer API",
      subtitle: "Update Vehicle in Fleetio Developer API",
      help: "Update a Vehicle. If you need to update many Vehicles at once, use the Bulk API to avoid Rate Limiting errors.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vehicles__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['VehicleTwo']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vehicles__Update_execute, connection, input, extended_input_schema)
      end
    },
    Vendors__Create: {
      title: "Create Vendor",
      hint: "Create Vendor in Fleetio Developer API",
      subtitle: "Create Vendor in Fleetio Developer API",
      help: "Creates a new Vendor",
      input_fields: lambda do |object_definitions|
        object_definitions['Vendors__Create_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Vendor']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vendors__Create_execute, connection, input, extended_input_schema)
      end
    },
    Vendors__Index: {
      title: "List Vendors",
      hint: "List Vendors in Fleetio Developer API",
      subtitle: "List Vendors in Fleetio Developer API",
      help: "Returns a list of Vendors belonging to your account.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vendors__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Vendors__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vendors__Index_execute, connection, input, extended_input_schema)
      end
    },
    Vendors__Show: {
      title: "Retrieve Vendor",
      hint: "Retrieve Vendor in Fleetio Developer API",
      subtitle: "Retrieve Vendor in Fleetio Developer API",
      help: "Retrieve the details of an existing Vendor.",
      input_fields: lambda do |object_definitions|
        object_definitions['Vendors__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Vendor']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vendors__Show_execute, connection, input, extended_input_schema)
      end
    },
    Vendors__Update: {
      title: "Update Vendor",
      hint: "Update Vendor in Fleetio Developer API",
      subtitle: "Update Vendor in Fleetio Developer API",
      help: "Update a Vendor",
      input_fields: lambda do |object_definitions|
        object_definitions['Vendors__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['Vendor']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:Vendors__Update_execute, connection, input, extended_input_schema)
      end
    },
    WorkOrders__Index: {
      title: "List Work Orders",
      hint: "List Work Orders in Fleetio Developer API",
      subtitle: "List Work Orders in Fleetio Developer API",
      help: "Returns a list of work orders.",
      input_fields: lambda do |object_definitions|
        object_definitions['WorkOrders__Index_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['WorkOrders__Index_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:WorkOrders__Index_execute, connection, input, extended_input_schema)
      end
    },
    WorkOrders__Show: {
      title: "Retrieve Work Order",
      hint: "Retrieve Work Order in Fleetio Developer API",
      subtitle: "Retrieve Work Order in Fleetio Developer API",
      help: "Retrieve the details of an existing Work Order.",
      input_fields: lambda do |object_definitions|
        object_definitions['WorkOrders__Show_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['WorkOrder']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:WorkOrders__Show_execute, connection, input, extended_input_schema)
      end
    },
    WorkOrders__Update: {
      title: "Update Work Order",
      hint: "Update Work Order in Fleetio Developer API",
      subtitle: "Update Work Order in Fleetio Developer API",
      help: "Update a Work Order",
      input_fields: lambda do |object_definitions|
        object_definitions['WorkOrders__Update_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['WorkOrder']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:WorkOrders__Update_execute, connection, input, extended_input_schema)
      end
    }
  },
  
  object_definitions: {
    ContactSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          {
            name: "id",
            optional: true,
            type: "integer",
          },
          {
            name: "created_at",
            optional: true,
            hint: "The date and time at which this record was created.",
            type: "date_time",
          },
          {
            name: "updated_at",
            optional: true,
            hint: "The date and time at which this record was most recently updated.",
            type: "date_time",
          },
          {
            name: "email",
            optional: true,
            hint: "The Contact's email address.",
            type: "string",
          },
          {
            name: "name",
            optional: false,
            hint: "The Contact's full name.",
            type: "string",
          },
          {
            name: "first_name",
            optional: false,
            hint: "The Contact's first name.",
            type: "string",
          },
          {
            name: "middle_name",
            optional: false,
            hint: "The Contact's middle name.",
            type: "string",
          },
          {
            name: "last_name",
            optional: false,
            hint: "The Contact's last name.",
            type: "string",
          },
          {
            name: "group_id",
            optional: false,
            hint: "If this Contact belongs to a Group, this will be the Fleetio ID of that Group.",
            type: "integer",
          },
          {
            name: "group_name",
            optional: false,
            hint: "If this Contact belongs to a Group, this will be the Group's name.",
            type: "string",
          },
          {
            name: "group_hierarchy",
            optional: true,
            hint: "If this Contact belongs to a Group, this will be a pipe delimited string representing the Group hierarchy. Each Group in the list is the parent of the Groups which follow.",
            type: "string",
          },
          {
            name: "technician",
            optional: true,
            hint: "Whether or not the Contact is a Technician.",
            type: "boolean",
          },
          {
            name: "vehicle_operator",
            optional: true,
            hint: "Whether or not the Contact is a Vehicle Operator.",
            type: "boolean",
          },
          {
            name: "employee",
            optional: true,
            hint: "Whether or not the Contact is an Employee.",
            type: "boolean",
          },
          {
            name: "birth_date",
            optional: true,
            hint: "The Contact's birth date.",
            type: "date",
          },
          {
            name: "street_address",
            optional: true,
            hint: "The Contact's street address.",
            type: "string",
          },
          {
            name: "street_address_line_2",
            optional: true,
            hint: "The Contact's street address line 2.",
            type: "string",
          },
          {
            name: "city",
            optional: true,
            hint: "The Contact's city.",
            type: "string",
          },
          {
            name: "region",
            optional: true,
            hint: "The Contact's region, state, or province.",
            type: "string",
          },
          {
            name: "postal_code",
            optional: true,
            hint: "The Contact's postal code, zip code, or equivalent.",
            type: "string",
          },
          {
            name: "country",
            optional: true,
            hint: "The Contact's country.",
            type: "string",
          },
          {
            name: "employee_number",
            optional: true,
            hint: "The Contact's employee number.",
            type: "string",
          },
          {
            name: "job_title",
            optional: true,
            hint: "The Contact's job title.",
            type: "string",
          },
          {
            name: "license_class",
            optional: true,
            hint: "The Contact's driver's license class.",
            type: "string",
          },
          {
            name: "license_number",
            optional: true,
            hint: "The Contact's driver's license number.",
            type: "string",
          },
          {
            name: "license_state",
            optional: true,
            hint: "The locality which issued the Contact's license.",
            type: "string",
          },
          {
            name: "home_phone_number",
            optional: true,
            hint: "The Contact's home phone number.",
            type: "string",
          },
          {
            name: "mobile_phone_number",
            optional: true,
            hint: "The Contact's mobile phone number.",
            type: "string",
          },
          {
            name: "work_phone_number",
            optional: true,
            hint: "The Contact's work phone number.",
            type: "string",
          },
          {
            name: "other_phone_number",
            optional: true,
            hint: "Any other phone number for this Contact.",
            type: "string",
          },
          {
            name: "start_date",
            optional: true,
            hint: "When the Contact started working for the company, if applicable.",
            type: "date",
          },
          {
            name: "leave_date",
            optional: true,
            hint: "When the Contact left or will leave the company, if applicable.",
            type: "date",
          },
          {
            name: "hourly_labor_rate_cents",
            optional: true,
            hint: "The Contact's hourly rate in cents.",
            type: "integer",
          },
          {
            name: "attachment_permissions",
            optional: true,
            type: "object",
            properties: [
              {
                name: "read_photos",
                optional: true,
                hint: "Indicates whether the user has read permission for photos.",
                type: "boolean",
              },
              {
                name: "manage_photos",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) photos.",
                type: "boolean",
              },
              {
                name: "read_documents",
                optional: true,
                hint: "Indicates whether the user has read permission for documents.",
                type: "boolean",
              },
              {
                name: "manage_documents",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) documents.",
                type: "boolean",
              },
            ],
          },
          {
            name: "default_image_url",
            optional: false,
            hint: "The URL of the Contact's default image/profile photo, if any.",
            type: "string",
          },
          {
            name: "account_membership_id",
            optional: true,
            type: "integer",
          },
          {
            name: "last_api_request",
            optional: true,
            hint: "The last date and time this Contact's associated User made an API request.  Null if Contact is not assocated with a User.",
            type: "date_time",
          },
          {
            name: "last_web_access",
            optional: true,
            hint: "The last date and time this Contact's associated User signed into the web application.  Null if Contact is not assocated with a User.",
            type: "date_time",
          },
          {
            name: "last_mobile_app_access",
            optional: true,
            hint: "The last date and time this Contact's associated User used the mobile app.  Null if Contact is not assocated with a User.",
            type: "date_time",
          },
          {
            name: "custom_fields",
            optional: true,
            type: "object",
          },
          {
            name: "images",
            optional: true,
            hint: "A list of the images attached to this record.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "number",
              },
              {
                name: "created_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "updated_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "imageable_id",
                optional: true,
                type: "number",
              },
              {
                name: "imageable_type",
                optional: true,
                type: "string",
                pick_list: [
                  ["ExpenseEntry", "ExpenseEntry"],
                  ["WorkOrder", "WorkOrder"],
                  ["Equipment", "Equipment"],
                  ["IssueResolution", "IssueResolution"],
                  ["ServiceEntry", "ServiceEntry"],
                  ["Vendor", "Vendor"],
                  ["ServiceProgram", "ServiceProgram"],
                  ["Issue", "Issue"],
                  ["Contact", "Contact"],
                  ["Part", "Part"],
                  ["Vehicle", "Vehicle"],
                  ["FuelEntry", "FuelEntry"],
                  ["SubmittedInspectionItem", "SubmittedInspectionItem"],
                ],
              },
              {
                name: "file_name",
                optional: true,
                hint: "The name of the image file.",
                type: "string",
              },
              {
                name: "file_mime_type",
                optional: true,
                type: "string",
                pick_list: [
                  ["image/jpeg", "image/jpeg"],
                  ["image/gif", "image/gif"],
                  ["image/jif", "image/jif"],
                  ["image/jfif", "image/jfif"],
                  ["image/jfi", "image/jfi"],
                  ["image/tiff", "image/tiff"],
                  ["image/png", "image/png"],
                  ["image/jpg", "image/jpg"],
                  ["image/jpe", "image/jpe"],
                  ["image/pdf", "image/pdf"],
                  ["image/webp", "image/webp"],
                  ["image/tif", "image/tif"],
                  ["image/psd", "image/psd"],
                  ["image/raw", "image/raw"],
                  ["image/arw", "image/arw"],
                  ["image/cr2", "image/cr2"],
                  ["image/nrw", "image/nrw"],
                  ["image/k25", "image/k25"],
                  ["image/bmp", "image/bmp"],
                  ["image/dip", "image/dip"],
                  ["image/ai", "image/ai"],
                  ["image/eps", "image/eps"],
                  ["image/heif", "image/heif"],
                  ["image/heic", "image/heic"],
                  ["image/ind", "image/ind"],
                  ["image/indd", "image/indd"],
                  ["image/indt", "image/indt"],
                  ["image/jp2", "image/jp2"],
                  ["image/j2k", "image/j2k"],
                  ["image/jpf", "image/jpf"],
                  ["image/jpx", "image/jpx"],
                  ["image/jpm", "image/jpm"],
                  ["image/mj2", "image/mj2"],
                  ["image/x-png", "image/x-png"],
                ],
              },
              {
                name: "file_size",
                optional: true,
                hint: "The size of the image file in bytes.",
                type: "number",
              },
              {
                name: "file_url",
                optional: true,
                hint: "The URL to access the image file.",
                type: "string",
              },
              {
                name: "full_url",
                optional: true,
                hint: "The full URL to access the image file, including any necessary authentication or parameters.",
                type: "string",
              },
            ],
          },
          {
            name: "images_count",
            optional: false,
            hint: "The number of images attached to this record.",
            type: "integer",
          },
        ]
      end
    },
    Contact_v2: {
      fields: lambda do |_, _, _object_definitions|
        [
          {
            name: "id",
            optional: true,
            type: "number",
          },
          {
            name: "created_at",
            optional: true,
            type: "date_time",
          },
          {
            name: "updated_at",
            optional: true,
            type: "date_time",
          },
          {
            name: "name",
            optional: false,
            hint: "The Contact's full name.",
            type: "string",
          },
          {
            name: "first_name",
            optional: false,
            hint: "The Contact's first name.",
            type: "string",
          },
          {
            name: "middle_name",
            optional: false,
            hint: "The Contact's middle name.",
            type: "string",
          },
          {
            name: "group_id",
            optional: false,
            hint: "If this Contact belongs to a Group, this will be the Fleetio ID of that Group.",
            type: "integer",
          },
          {
            name: "group_name",
            optional: false,
            hint: "If this Contact belongs to a Group, this will be the Group's name.",
            type: "string",
          },
          {
            name: "last_name",
            optional: false,
            hint: "The Contact's last name.",
            type: "string",
          },
          {
            name: "images_count",
            optional: false,
            hint: "The number of images associated with this Contact.",
            type: "integer",
          },
          {
            name: "documents_count",
            optional: false,
            hint: "The number of documents associated with this Contact.",
            type: "integer",
          },
          {
            name: "comments_count",
            optional: false,
            hint: "The number of Comments associated with this Contact.",
            type: "integer",
          },
          {
            name: "email",
            optional: true,
            hint: "The Contact's email address.",
            type: "string",
          },
          {
            name: "technician",
            optional: true,
            hint: "Whether this Contact is a Technician.",
            type: "boolean",
          },
          {
            name: "vehicle_operator",
            optional: true,
            hint: "Whether this Contact is a Vehicle Operator.",
            type: "boolean",
          },
          {
            name: "employee",
            optional: true,
            hint: "Whether this Contact is an Employee.",
            type: "boolean",
          },
          {
            name: "birth_date",
            optional: true,
            hint: "The Contact's birth date.",
            type: "date",
          },
          {
            name: "street_address",
            optional: true,
            hint: "The Contact's street address.",
            type: "string",
          },
          {
            name: "street_address_line_2",
            optional: true,
            hint: "The second line of the Contact's street address.",
            type: "string",
          },
          {
            name: "city",
            optional: true,
            hint: "The Contact's city.",
            type: "string",
          },
          {
            name: "region",
            optional: true,
            hint: "The Contact's region.",
            type: "string",
          },
          {
            name: "postal_code",
            optional: true,
            hint: "The Contact's postal code.",
            type: "string",
          },
          {
            name: "country",
            optional: true,
            hint: "The Contact's country.",
            type: "string",
          },
          {
            name: "employee_number",
            optional: true,
            hint: "The Contact's employee number.",
            type: "string",
          },
          {
            name: "job_title",
            optional: true,
            hint: "The Contact's job title.",
            type: "string",
          },
          {
            name: "license_class",
            optional: true,
            hint: "The Contact's license class.",
            type: "string",
          },
          {
            name: "license_number",
            optional: true,
            hint: "The Contact's license number.",
            type: "string",
          },
          {
            name: "license_state",
            optional: true,
            hint: "The state which issued the Contact's license.",
            type: "string",
          },
          {
            name: "license_expiration",
            optional: true,
            hint: "The Contact's driver's license expiration date.",
            type: "date",
          },
          {
            name: "home_phone_number",
            optional: true,
            hint: "The Contact's home phone number.",
            type: "string",
          },
          {
            name: "mobile_phone_number",
            optional: true,
            hint: "The Contact's mobile phone number.",
            type: "string",
          },
          {
            name: "work_phone_number",
            optional: true,
            hint: "The Contact's work phone number.",
            type: "string",
          },
          {
            name: "other_phone_number",
            optional: true,
            hint: "Any other mobile phone number belonging to this Contact.",
            type: "string",
          },
          {
            name: "start_date",
            optional: true,
            hint: "The Contact's start date.",
            type: "date",
          },
          {
            name: "leave_date",
            optional: true,
            hint: "The Contact's leave date.",
            type: "date",
          },
          {
            name: "hourly_labor_rate",
            optional: true,
            hint: "The Contact's hourly rate.",
            type: "number",
          },
          {
            name: "custom_fields",
            optional: true,
            type: "object",
          },
          {
            name: "default_image_url",
            optional: false,
            hint: "The URL pointing to the default image for this Contact.",
            type: "string",
          },
          {
            name: "account_membership_id",
            optional: true,
            type: "integer",
          },
          {
            name: "archived_at",
            optional: true,
            hint: "The date and time at which this Contact was archived, if applicable. null if this Contact is not archived.",
            type: "date_time",
          },
          {
            name: "user",
            optional: false,
            type: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "integer",
              },
              {
                name: "email",
                optional: true,
                hint: "The email address associated with this User.",
                type: "string",
              },
              {
                name: "username",
                optional: true,
                hint: "The username of this User.",
                type: "string",
              },
              {
                name: "time_zone",
                optional: true,
                hint: "The timezone set for this User.",
                type: "string",
              },
              {
                name: "user_type",
                optional: true,
                hint: "This User's type.",
                type: "string",
                pick_list: [
                  ["admin", "admin"],
                  ["regular", "regular"],
                  ["owner", "owner"],
                ],
              },
              {
                name: "archived_at",
                optional: true,
                hint: "The date and time at which the User was archived (deactivated). If null, the User is not deactivated.",
                type: "date_time",
              },
              {
                name: "role",
                optional: true,
                hint: "Basic information about this User's Role, if applicable.",
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
              {
                name: "vehicles_record_set",
                optional: true,
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
              {
                name: "equipments_record_set",
                optional: true,
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
              {
                name: "contacts_record_set",
                optional: true,
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
              {
                name: "parts_record_set",
                optional: true,
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
              {
                name: "inspection_forms_record_set",
                optional: true,
                type: "object",
                properties: [
                  {
                    name: "id",
                    optional: true,
                    type: "integer",
                  },
                  {
                    name: "name",
                    optional: true,
                    type: "string",
                  },
                ],
              },
            ],
          },
        ]
      end
    },
    EquipmentEquipmentAssignmentSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          {
            name: "id",
            optional: false,
            type: "integer",
          },
          {
            name: "created_at",
            optional: false,
            type: "date_time",
          },
          {
            name: "updated_at",
            optional: false,
            type: "date_time",
          },
          {
            name: "equipment_id",
            optional: false,
            hint: "The id of the equipment associated with this Equipment Assignment.",
            type: "integer",
          },
          {
            name: "contact_id",
            optional: false,
            hint: "The id of the contact associated with this Equipemnt Assignment.",
            type: "integer",
          },
          {
            name: "started_at",
            optional: false,
            hint: "The date and time of this Equipemnt Assignment. Dates in the future are accepted. We recommend using ISO-8601 formatted dates to avoid ambiguity.",
            type: "date_time",
          },
          {
            name: "ended_at",
            optional: false,
            hint: "The date and time of this Equipment Assignment ending. We recommend using ISO-8601 formatted dates to avoid ambiguity.",
            type: "date_time",
          },
          {
            name: "current",
            optional: false,
            hint: "Whether this Equipment Assignment is current/active.",
            type: "boolean",
          },
          {
            name: "future",
            optional: false,
            hint: "Whether this Equipment Assignment is set to take place in the future.",
            type: "boolean",
          },
          {
            name: "contact",
            optional: false,
            type: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "integer",
              },
              {
                name: "email",
                optional: true,
                hint: "The Contact's email address.",
                type: "string",
              },
              {
                name: "name",
                optional: true,
                hint: "The Contact's full name.",
                type: "string",
              },
              {
                name: "group_id",
                optional: true,
                hint: "If this Contact belongs to a Group, this will be the Fleetio ID of that Group.",
                type: "integer",
              },
              {
                name: "employee",
                optional: true,
                hint: "Whether or not the Contact is an employee.",
                type: "boolean",
              },
              {
                name: "employee_number",
                optional: true,
                hint: "The employee number of the  Contact.",
                type: "string",
              },
              {
                name: "default_image_url",
                optional: true,
                hint: "The URL of the Contact's default image/profile photo, if any.",
                type: "string",
              },
            ],
          },
          {
            name: "equipment",
            optional: false,
            type: "object",
            properties: [
              {
                name: "id",
                optional: false,
                type: "integer",
              },
              {
                name: "name",
                optional: false,
                hint: "The name for this Equipment.",
                type: "string",
              },
              {
                name: "brand",
                optional: false,
                hint: "The name of the brand which makes this Equipment.",
                type: "string",
              },
              {
                name: "model",
                optional: false,
                hint: "The model name of this Equipment.",
                type: "string",
              },
              {
                name: "serial_number",
                optional: false,
                hint: "The serial number of this Equipment.",
                type: "string",
              },
            ],
          },
        ]
      end
    },
    WorkOrderSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          {
            name: "id",
            optional: false,
            type: "integer",
          },
          {
            name: "number",
            optional: false,
            hint: "The unique number of this Work Order.",
            type: "string",
          },
          {
            name: "completed_at",
            optional: false,
            hint: "The date and time at which the Work Order was completed.",
            type: "date_time",
          },
          {
            name: "description",
            optional: false,
            hint: "A description of this Work Order.",
            type: "string",
          },
          {
            name: "ending_meter_same_as_start",
            optional: false,
            hint: "Indicates whether or not the ending meter is the same as the starting meter.",
            type: "boolean",
          },
          {
            name: "duration_in_seconds",
            optional: false,
            hint: "The number of seconds elapsed between beginning this Work Order and completing it.",
            type: "integer",
          },
          {
            name: "invoice_number",
            optional: false,
            hint: "The number of the Invoice associated with this Work Order.",
            type: "string",
          },
          {
            name: "created_by_id",
            optional: false,
            hint: "The id of the User who created this Work Order.",
            type: "integer",
          },
          {
            name: "state",
            optional: false,
            hint: "Indicates whether this Work Order is currently active or has already been completed.",
            type: "string",
            pick_list: [
              ["active", "active"],
              ["completed", "completed"],
            ],
          },
          {
            name: "issued_at",
            optional: false,
            hint: "The date and time at which the Work Order was issued.",
            type: "date_time",
          },
          {
            name: "issued_by_id",
            optional: false,
            hint: "The id of the issuer of this Work Order.",
            type: "integer",
          },
          {
            name: "contact_id",
            optional: false,
            hint: "The id of the Contact assigned to this Work Order.",
            type: "integer",
          },
          {
            name: "purchase_order_number",
            optional: false,
            hint: "The purchase order number for this Work Order.",
            type: "string",
          },
          {
            name: "scheduled_at",
            optional: false,
            hint: "The date and time at which the Work Order was scheduled.",
            type: "date_time",
          },
          {
            name: "started_at",
            optional: false,
            hint: "The date and time at which the Work Order was started.",
            type: "date_time",
          },
          {
            name: "expected_completed_at",
            optional: false,
            hint: "The date and time at which the Work Order is expected to be completed.",
            type: "date_time",
          },
          {
            name: "vehicle_id",
            optional: false,
            hint: "The id of the Vehicle associated with this Work Order.",
            type: "integer",
          },
          {
            name: "work_order_status_id",
            optional: false,
            hint: "The id of the WorkOrderStatus for this Work Order.",
            type: "integer",
          },
          {
            name: "work_order_status_color",
            optional: true,
            hint: "The color of the Work Order Status for this Work Order.",
            type: "string",
          },
          {
            name: "work_order_status_name",
            optional: false,
            hint: "The name of the Work Order Status for this Work Order.",
            type: "string",
          },
          {
            name: "documents_count",
            optional: false,
            hint: "The count of associated documents.",
            type: "integer",
          },
          {
            name: "images_count",
            optional: false,
            hint: "The count of the associated images.",
            type: "integer",
          },
          {
            name: "comments_count",
            optional: false,
            hint: "The count of associated comments.",
            type: "integer",
          },
          {
            name: "created_at",
            optional: false,
            hint: "The date and time at which the Work Order was created.",
            type: "date_time",
          },
          {
            name: "updated_at",
            optional: false,
            hint: "The date and time at which the Work Order was last updated.",
            type: "date_time",
          },
          {
            name: "labor_time_in_seconds",
            optional: true,
            hint: "The sum, in seconds, of the duration of all labor line items of a completed Work Order.",
            type: "integer",
          },
          {
            name: "attachment_permissions",
            optional: true,
            type: "object",
            properties: [
              {
                name: "read_photos",
                optional: true,
                hint: "Indicates whether the user has read permission for photos.",
                type: "boolean",
              },
              {
                name: "manage_photos",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) photos.",
                type: "boolean",
              },
              {
                name: "read_documents",
                optional: true,
                hint: "Indicates whether the user has read permission for documents.",
                type: "boolean",
              },
              {
                name: "manage_documents",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) documents.",
                type: "boolean",
              },
            ],
          },
          {
            name: "custom_fields",
            optional: true,
            type: "object",
          },
          {
            name: "contact",
            optional: false,
            hint: "A Contact",
            type: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "integer",
              },
              {
                name: "email",
                optional: true,
                hint: "The Contact's email address.",
                type: "string",
              },
              {
                name: "name",
                optional: true,
                hint: "The Contact's full name.",
                type: "string",
              },
              {
                name: "group_id",
                optional: true,
                hint: "If this Contact belongs to a Group, this will be the Fleetio ID of that Group.",
                type: "integer",
              },
              {
                name: "employee",
                optional: true,
                hint: "Whether or not the Contact is an employee.",
                type: "boolean",
              },
              {
                name: "employee_number",
                optional: true,
                hint: "The employee number of the  Contact.",
                type: "string",
              },
              {
                name: "default_image_url",
                optional: true,
                hint: "The URL of the Contact's default image/profile photo, if any.",
                type: "string",
              },
            ],
          },
          {
            name: "vehicle",
            optional: false,
            hint: "A Vehicle",
            type: "object",
            properties: [
              {
                name: "id",
                optional: false,
                type: "integer",
              },
              {
                name: "name",
                optional: false,
                hint: "This vehicle's name.",
                type: "string",
              },
              {
                name: "color",
                optional: true,
                hint: "The color of this Vehicle.",
                type: "string",
              },
              {
                name: "license_plate",
                optional: true,
                hint: "The license plate number of this Vehicle.",
                type: "string",
              },
              {
                name: "vin",
                optional: true,
                hint: "The Vehicle Identification Number of this Vehicle.",
                type: "string",
              },
              {
                name: "year",
                optional: true,
                hint: "This Vehicle's model year.",
                type: "string",
              },
              {
                name: "make",
                optional: true,
                hint: "The name of this Vehicle's manufacturer.",
                type: "string",
              },
              {
                name: "model",
                optional: true,
                hint: "The name of the model of this Vehicle.",
                type: "string",
              },
              {
                name: "trim",
                optional: true,
                hint: "The trim level of this Vehicle.",
                type: "string",
              },
              {
                name: "registration_expiration_month",
                optional: true,
                hint: "The month in which this Vehicle's registration expires.",
                type: "integer",
              },
              {
                name: "registration_state",
                optional: true,
                hint: "The state, province, or territory in which this Vehicle is registered.",
                type: "string",
              },
              {
                name: "default_image_url_small",
                optional: true,
                hint: "The URL of a small-sized version of the default image for this Vehicle.",
                type: "string",
              },
            ],
          },
          {
            name: "vendor",
            optional: false,
            hint: "A Vendor",
            type: "object",
            properties: [
              {
                name: "name",
                optional: false,
                hint: "The name of the Vendor.",
                type: "string",
              },
              {
                name: "phone",
                optional: false,
                hint: "The phone number of the Vendor.",
                type: "string",
              },
              {
                name: "city",
                optional: false,
                hint: "The city of the Vendor.",
                type: "string",
              },
              {
                name: "region",
                optional: false,
                hint: "The region, state, province, or territory of the Vendor.",
                type: "string",
              },
              {
                name: "postal_code",
                optional: false,
                hint: "The postal code or ZIP code of the Vendor.",
                type: "string",
              },
              {
                name: "country",
                optional: false,
                hint: "The country of the Vendor.",
                type: "string",
              },
              {
                name: "external_id",
                optional: false,
                hint: "The external identifier of the Vendor.",
                type: "string",
              },
            ],
          },
        ]
      end
    },
    WorkOrders__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "start_cursor",
            optional: true,
            hint: "The current start cursor of the records returned.",
            type: "string",
          },
          {
            name: "next_cursor",
            optional: true,
            hint: "The next cursor to retrieve the next page of records.",
            type: "string",
          },
          {
            name: "per_page",
            optional: true,
            hint: "The maxumum number of records returned.",
            type: "integer",
          },
          {
            name: "estimated_remaining_count",
            optional: true,
            hint: "The number of remaining records including the returned records, up to a maximum of 500.",
            type: "integer",
          },
          {
            name: "filtered_by",
            optional: true,
            hint: "The filters applied to the returned record set.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "contact_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "created_by_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "issued_by_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "vehicle_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "vendor_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "vmrs_repair_priority_class_id",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "purchase_order_number",
                optional: true,
                type: "object",
                properties: [
                  { name: "like", optional: true, type: "string" },
                  { name: "eq", optional: true, type: "string" }
                ]
              },
              {
                name: "invoice_number",
                optional: true,
                type: "object",
                properties: [
                  { name: "like", optional: true, type: "string" },
                  { name: "eq", optional: true, type: "string" }
                ]
              },
              {
                name: "number",
                optional: true,
                type: "object",
                properties: [
                  { name: "eq", optional: false, type: "string" }
                ]
              },
              {
                name: "labels",
                optional: true,
                type: "object",
                properties: [
                  { name: "include", optional: false, type: "string" }
                ]
              },
              {
                name: "created_at",
                optional: true,
                type: "object",
                properties: [
                  { name: "lt", optional: true, type: "string" },
                  { name: "lte", optional: true, type: "string" },
                  { name: "gt", optional: true, type: "string" },
                  { name: "gte", optional: true, type: "string" }
                ]
              },
              {
                name: "updated_at",
                optional: true,
                type: "object",
                properties: [
                  { name: "lt", optional: true, type: "string" },
                  { name: "lte", optional: true, type: "string" },
                  { name: "gt", optional: true, type: "string" },
                  { name: "gte", optional: true, type: "string" }
                ]
              }
            ]
          },
          {
            name: "sorted_by",
            optional: true,
            hint: "The sorts applied to the returned record set.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "created_at",
                optional: true,
                type: "string",
                pick_list: [["asc", "asc"], ["desc", "desc"]]
              },
              {
                name: "updated_at",
                optional: true,
                type: "string",
                pick_list: [["asc", "asc"], ["desc", "desc"]]
              },
              {
                name: "id",
                optional: true,
                type: "string",
                pick_list: [["asc", "asc"], ["desc", "desc"]]
              }
            ]
          },
          {
            name: "records",
            optional: true,
            type: "array",
            of: "object",
            properties: object_definitions["WorkOrderSummary"]
          }
        ]
      end
    },
    WorkOrder: {
      fields: lambda do |_, _, _object_definitions|
        [
          {
            name: "id",
            optional: false,
            type: "number",
          },
          {
            name: "created_at",
            optional: true,
            hint: "The date and time at which this record was created.",
            type: "date_time",
          },
          {
            name: "updated_at",
            optional: true,
            hint: "The date and time at which this record was most recently updated.",
            type: "date_time",
          },
          {
            name: "number",
            optional: false,
            hint: "The unique number of this Work Order.",
            type: "string",
          },
          {
            name: "completed_at",
            optional: false,
            hint: "The date and time at which the Work Order was completed.",
            type: "date_time",
          },
          {
            name: "description",
            optional: false,
            hint: "A description of this Work Order.",
            type: "string",
          },
          {
            name: "ending_meter_same_as_start",
            optional: false,
            hint: "Indicates whether or not the ending meter is the same as the starting meter.",
            type: "boolean",
          },
          {
            name: "duration_in_seconds",
            optional: false,
            hint: "The number of seconds elapsed between beginning this Work Order and completing it.",
            type: "integer",
          },
          {
            name: "invoice_number",
            optional: false,
            hint: "The number of the Invoice associated with this Work Order.",
            type: "string",
          },
          {
            name: "created_by_id",
            optional: false,
            hint: "The id of the User who created this Work Order.",
            type: "integer",
          },
          {
            name: "state",
            optional: false,
            hint: "Indicates whether this Work Order is currently active or has already been completed.",
            type: "string",
            pick_list: [
              ["active", "active"],
              ["completed", "completed"],
            ],
          },
          {
            name: "issued_at",
            optional: false,
            hint: "The date and time at which the Work Order was issued.",
            type: "date_time",
          },
          {
            name: "issued_by_id",
            optional: false,
            type: "integer",
          },
          {
            name: "issued_by_name",
            optional: false,
            hint: "The name of the Contact associated with the User who issued this Work Order.",
            type: "string",
          },
          {
            name: "contact_id",
            optional: false,
            type: "integer",
          },
          {
            name: "contact_name",
            optional: false,
            hint: "The name of the Contact currently assigned to this Work Order.",
            type: "string",
          },
          {
            name: "purchase_order_number",
            optional: false,
            hint: "The number of any Purchase Order associated with this Work Order.",
            type: "string",
          },
          {
            name: "started_at",
            optional: false,
            hint: "The date and time at which the Work Order was started.",
            type: "date_time",
          },
          {
            name: "expected_completed_at",
            optional: true,
            hint: "The date and time at which the Work Order is expected to be completed.",
            type: "date_time",
          },
          {
            name: "contact_image_url",
            optional: true,
            hint: "The URL of the image associated with the Contact currently assigned to this Work Order.",
            type: "string",
          },
          {
            name: "scheduled_at",
            optional: false,
            hint: "The date and time at which the Work Order was scheduled.",
            type: "date_time",
          },
          {
            name: "vehicle_id",
            optional: false,
            type: "number",
          },
          {
            name: "vehicle_name",
            optional: false,
            hint: "The name of the Vehicle associated with this Work Order.",
            type: "string",
          },
          {
            name: "vendor_id",
            optional: false,
            type: "integer",
          },
          {
            name: "vendor_name",
            optional: false,
            hint: "The name of the Vendor associated with this Work Order.",
            type: "string",
          },
          {
            name: "work_order_status_id",
            optional: false,
            type: "number",
          },
          {
            name: "work_order_status_name",
            optional: false,
            hint: "The name of the Work Order Status associated with this Work Order.",
            type: "string",
          },
          {
            name: "work_order_status_color",
            optional: false,
            hint: "The color of the Work Order Status seen in the UI.",
            type: "string",
          },
          {
            name: "custom_fields",
            optional: false,
            type: "object",
          },
          {
            name: "attachment_permissions",
            optional: true,
            type: "object",
            properties: [
              {
                name: "read_photos",
                optional: true,
                hint: "Indicates whether the user has read permission for photos.",
                type: "boolean",
              },
              {
                name: "manage_photos",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) photos.",
                type: "boolean",
              },
              {
                name: "read_documents",
                optional: true,
                hint: "Indicates whether the user has read permission for documents.",
                type: "boolean",
              },
              {
                name: "manage_documents",
                optional: true,
                hint: "Indicates whether the user has permission to manage (eg. upload, delete) documents.",
                type: "boolean",
              },
            ],
          },
          {
            name: "vmrs_repair_priority_class",
            optional: false,
            hint: "The VMRS Repair Priority Class associated with this Work Order.",
            type: "object",
            properties: [
              {
                name: "id",
                optional: true,
                hint: "The ID of the VMRS Repair Priority Class.",
                type: "integer",
              },
              {
                name: "code",
                optional: true,
                hint: "The code of the VMRS Repair Priority Class.",
                type: "string",
              },
              {
                name: "name",
                optional: true,
                hint: "The name of the VMRS Repair Priority Class.",
                type: "string",
              },
              {
                name: "color",
                optional: true,
                hint: "The color of the VMRS Repair Priority Class.",
                type: "string",
              },
            ],
          },
          {
            name: "labels",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "number",
              },
              {
                name: "name",
                optional: true,
                type: "string",
              },
            ],
          },
          {
            name: "issues",
            optional: false,
            hint: "Any Issues associated with this Work Order.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                hint: "The ID of the Issue.",
                type: "integer",
              },
              {
                name: "name",
                optional: true,
                hint: "The name of the Issue.",
                type: "string",
              },
            ],
          },
          {
            name: "watchers_count",
            optional: true,
            hint: "The number of Users watching this Work Order.",
            type: "integer",
          },
          {
            name: "is_watched",
            optional: true,
            hint: "Indicates whether the current User is watching this Work Order.",
            type: "boolean",
          },
          {
            name: "discount_type",
            optional: false,
            hint: "The type of discount applied to this record.",
            type: "string",
            pick_list: [
              ["fixed", "fixed"],
              ["percentage", "percentage"],
            ],
          },
          {
            name: "discount_percentage",
            optional: false,
            hint: "The discount percentage. This field should be present when discount_type is set to percentage.",
            type: "number",
          },
          {
            name: "discount",
            optional: false,
            hint: "The discount amount.",
            type: "number",
          },
          {
            name: "parts_subtotal",
            optional: false,
            hint: "The total cost of parts for this record.",
            type: "number",
          },
          {
            name: "labor_subtotal",
            optional: false,
            hint: "The total cost of labor for this record.",
            type: "number",
          },
          {
            name: "subtotal",
            optional: false,
            hint: "The pre-tax subtotal amount.",
            type: "number",
          },
          {
            name: "tax_1_type",
            optional: false,
            hint: "The type of tax to apply to this record.",
            type: "string",
            pick_list: [
              ["fixed", "fixed"],
              ["percentage", "percentage"],
            ],
          },
          {
            name: "tax_1_percentage",
            optional: false,
            hint: "The primary tax percentage amount. This field should be present when tax_1_type is set to percentage.",
            type: "number",
          },
          {
            name: "tax_2_type",
            optional: false,
            hint: "The type of tax to apply to this record.",
            type: "string",
            pick_list: [
              ["fixed", "fixed"],
              ["percentage", "percentage"],
            ],
          },
          {
            name: "tax_2_percentage",
            optional: false,
            hint: "The secondary tax percentage amount. This field should be present when tax_2_type is set to percentage. Note that this secondary tax must be configured in your Account Settings.",
            type: "number",
          },
          {
            name: "tax_1",
            optional: false,
            hint: "The primary tax amount.",
            type: "number",
          },
          {
            name: "tax_2",
            optional: false,
            hint: "The secondary tax amount. Note that this secondary tax must be configured in your Account Settings.",
            type: "number",
          },
          {
            name: "parts_markup_type",
            optional: true,
            hint: "The type of parts markup applied to the record Note that this is a readonly value that will default to percentage for non-premium plans",
            type: "string",
            pick_list: [
              ["fixed", "fixed"],
              ["percentage", "percentage"],
            ],
          },
          {
            name: "parts_markup",
            optional: true,
            hint: "The parts markup amount. Note that this is a readonly value that will default to 0.0 for non-premium plans",
            type: "number",
          },
          {
            name: "parts_markup_percentage",
            optional: true,
            hint: "The parts markup percentage amount. This field should be present when parts_markup_type is set to percentage. Note that this is a readonly value that will default to 0.0 for non-premium plans",
            type: "number",
          },
          {
            name: "labor_markup_type",
            optional: true,
            hint: "The type of labor markup applied to the record Note that this is a readonly value that will default to percentage for non-premium plans",
            type: "string",
            pick_list: [
              ["fixed", "fixed"],
              ["percentage", "percentage"],
            ],
          },
          {
            name: "labor_markup",
            optional: true,
            hint: "The labor markup amount. Note that this is a readonly value that will default to 0.0 for non-premium plans",
            type: "number",
          },
          {
            name: "labor_markup_percentage",
            optional: true,
            hint: "The labor markup percentage amount. This field should be present when labor_markup_type is set to percentage. Note that this is a readonly value that will default to 0.0 for non-premium plans",
            type: "number",
          },
          {
            name: "total_amount",
            optional: false,
            hint: "The total amount.",
            type: "number",
          },
          {
            name: "labor_time_in_seconds",
            optional: true,
            hint: "The sum, in seconds, of the duration of all labor line items of a completed Work Order.",
            type: "integer",
          },
          {
            name: "comments",
            optional: true,
            hint: "A list of the comments made on this record.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "number",
              },
              {
                name: "created_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "updated_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "commentable_type",
                optional: false,
                hint: "The type of record that the Comment will be left on. Must be associated with a matching commentable_id.",
                type: "string",
                pick_list: [
                  ["Contact", "Contact"],
                  ["FleetcorCard", "FleetcorCard"],
                  ["FuelEntry", "FuelEntry"],
                  ["InventoryJournalEntry", "InventoryJournalEntry"],
                  ["Issue", "Issue"],
                  ["Part", "Part"],
                  ["PurchaseOrder", "PurchaseOrder"],
                  ["ServiceEntry", "ServiceEntry"],
                  ["ServiceReminder", "ServiceReminder"],
                  ["SubmittedInspectionItem", "SubmittedInspectionItem"],
                  ["Vehicle", "Vehicle"],
                  ["VehicleAssignment", "VehicleAssignment"],
                  ["Vendor", "Vendor"],
                  ["WexCard", "WexCard"],
                  ["WorkOrder", "WorkOrder"],
                ],
              },
              {
                name: "commentable_id",
                optional: false,
                type: "number",
              },
              {
                name: "user_id",
                optional: false,
                type: "number",
              },
              {
                name: "title",
                optional: true,
                hint: "The title of the Comment.",
                type: "string",
              },
              {
                name: "comment",
                optional: false,
                hint: "The content of the Comment message body.",
                type: "string",
              },
              {
                name: "user_full_name",
                optional: false,
                hint: "The full name of the User who created the Comment.",
                type: "string",
              },
              {
                name: "user_image_url",
                optional: false,
                hint: "The image url for the User who created the Comment.",
                type: "string",
              },
              {
                name: "rich_content",
                optional: false,
                type: "object",
              },
              {
                name: "html_content",
                optional: false,
                hint: "The comment message body rendered as HTML.",
                type: "string",
              },
              {
                name: "with_mentions",
                optional: false,
                hint: "Indicates if the message body contains @mentions.",
                type: "boolean",
              },
            ],
          },
          {
            name: "comments_count",
            optional: true,
            hint: "The number of comments made on this record.",
            type: "integer",
          },
          {
            name: "images",
            optional: true,
            hint: "A list of the images attached to this record.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "number",
              },
              {
                name: "created_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "updated_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "imageable_id",
                optional: true,
                type: "number",
              },
              {
                name: "imageable_type",
                optional: true,
                type: "string",
                pick_list: [
                  ["ExpenseEntry", "ExpenseEntry"],
                  ["WorkOrder", "WorkOrder"],
                  ["Equipment", "Equipment"],
                  ["IssueResolution", "IssueResolution"],
                  ["ServiceEntry", "ServiceEntry"],
                  ["Vendor", "Vendor"],
                  ["ServiceProgram", "ServiceProgram"],
                  ["Issue", "Issue"],
                  ["Contact", "Contact"],
                  ["Part", "Part"],
                  ["Vehicle", "Vehicle"],
                  ["FuelEntry", "FuelEntry"],
                  ["SubmittedInspectionItem", "SubmittedInspectionItem"],
                ],
              },
              {
                name: "file_name",
                optional: true,
                hint: "The name of the image file.",
                type: "string",
              },
              {
                name: "file_mime_type",
                optional: true,
                type: "string",
                pick_list: [
                  ["image/jpeg", "image/jpeg"],
                  ["image/gif", "image/gif"],
                  ["image/jif", "image/jif"],
                  ["image/jfif", "image/jfif"],
                  ["image/jfi", "image/jfi"],
                  ["image/tiff", "image/tiff"],
                  ["image/png", "image/png"],
                  ["image/jpg", "image/jpg"],
                  ["image/jpe", "image/jpe"],
                  ["image/pdf", "image/pdf"],
                  ["image/webp", "image/webp"],
                  ["image/tif", "image/tif"],
                  ["image/psd", "image/psd"],
                  ["image/raw", "image/raw"],
                  ["image/arw", "image/arw"],
                  ["image/cr2", "image/cr2"],
                  ["image/nrw", "image/nrw"],
                  ["image/k25", "image/k25"],
                  ["image/bmp", "image/bmp"],
                  ["image/dip", "image/dip"],
                  ["image/ai", "image/ai"],
                  ["image/eps", "image/eps"],
                  ["image/heif", "image/heif"],
                  ["image/heic", "image/heic"],
                  ["image/ind", "image/ind"],
                  ["image/indd", "image/indd"],
                  ["image/indt", "image/indt"],
                  ["image/jp2", "image/jp2"],
                  ["image/j2k", "image/j2k"],
                  ["image/jpf", "image/jpf"],
                  ["image/jpx", "image/jpx"],
                  ["image/jpm", "image/jpm"],
                  ["image/mj2", "image/mj2"],
                  ["image/x-png", "image/x-png"],
                ],
              },
              {
                name: "file_size",
                optional: true,
                hint: "The size of the image file in bytes.",
                type: "number",
              },
              {
                name: "file_url",
                optional: true,
                hint: "The URL to access the image file.",
                type: "string",
              },
              {
                name: "full_url",
                optional: true,
                hint: "The full URL to access the image file, including any necessary authentication or parameters.",
                type: "string",
              },
            ],
          },
          {
            name: "images_count",
            optional: true,
            hint: "The number of images attached to this record.",
            type: "integer",
          },
          {
            name: "documents",
            optional: true,
            hint: "A list of the documents attached to this record.",
            type: "array",
            of: "object",
            properties: [
              {
                name: "id",
                optional: true,
                type: "number",
              },
              {
                name: "created_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "updated_at",
                optional: true,
                type: "date_time",
              },
              {
                name: "name",
                optional: false,
                hint: "The name of the document.",
                type: "string",
              },
              {
                name: "description",
                optional: false,
                hint: "The description of the document.",
                type: "string",
              },
              {
                name: "documentable_id",
                optional: false,
                type: "number",
              },
              {
                name: "documentable_type",
                optional: false,
                type: "string",
                pick_list: [
                  ["ServiceEntry", "ServiceEntry"],
                  ["FuelEntry", "FuelEntry"],
                  ["Issue", "Issue"],
                  ["WorkOrder", "WorkOrder"],
                  ["ExpenseEntry", "ExpenseEntry"],
                  ["Vehicle", "Vehicle"],
                ],
              },
              {
                name: "file_name",
                optional: false,
                hint: "The name of the file.",
                type: "string",
              },
              {
                name: "file_mime_type",
                optional: false,
                hint: "The MIME type of the file.",
                type: "string",
              },
              {
                name: "file_size",
                optional: false,
                hint: "The size of the file in bytes.",
                type: "number",
              },
              {
                name: "file_url",
                optional: false,
                hint: "The URL to access the file.",
                type: "string",
              },
              {
                name: "full_file_url",
                optional: false,
                hint: "The full URL to access the file, including any necessary authentication or parameters.",
                type: "string",
              },
            ],
          },
          {
            name: "documents_count",
            optional: true,
            hint: "The number of documents attached to this record.",
            type: "integer",
          },
        ]
      end
    },
    VendorSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "created_at", optional: false, type: "date_time" },
          { name: "updated_at", optional: false, type: "date_time" },
          { name: "name", optional: false, hint: "The name of the Vendor.", type: "string" },
          { name: "phone", optional: false, hint: "The phone number of the Vendor.", type: "string" },
          { name: "street_address", optional: false, hint: "The street address of the Vendor.", type: "string" },
          { name: "street_address_line_2", optional: false, hint: "The second line of the street address of the Vendor.", type: "string" },
          { name: "city", optional: false, hint: "The city of the Vendor.", type: "string" },
          { name: "region", optional: false, hint: "The region, state, province, or territory of the Vendor.", type: "string" },
          { name: "postal_code", optional: false, hint: "The postal code or ZIP code of the Vendor.", type: "string" },
          { name: "country", optional: false, hint: "The country of the Vendor.", type: "string" },
          { name: "website", optional: false, hint: "The website of the Vendor.", type: "string" },
          { name: "notes", optional: false, hint: "Additional notes about the Vendor.", type: "string" },
          { name: "fuel", optional: false, hint: "Indicates whether the Vendor provides fuel.", type: "boolean" },
          { name: "service", optional: false, hint: "Indicates whether the Vendor provides service.", type: "boolean" },
          { name: "parts", optional: false, hint: "Indicates whether the Vendor provides parts.", type: "boolean" },
          { name: "vehicle", optional: false, hint: "Indicates whether the Vendor provides vehicles.", type: "boolean" },
          { name: "contact_name", optional: false, hint: "The name of the contact person for the Vendor.", type: "string" },
          { name: "contact_email", optional: false, hint: "The email address of the contact person for the Vendor.", type: "string" },
          { name: "contact_phone", optional: false, hint: "The phone number of the contact person for the Vendor.", type: "string" },
          { name: "latitude", optional: false, hint: "The latitude of the Vendor's location.", type: "number" },
          { name: "longitude", optional: false, hint: "The longitude of the Vendor's location.", type: "number" },
          { name: "external_id", optional: false, hint: "The external identifier of the Vendor.", type: "string" },
          { name: "archived_at", optional: false, hint: "The date and time when the Vendor was archived, if applicable.", type: "string" },
          { name: "custom_fields", optional: true, type: "object" },
          {
            name: "labels",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: true, type: "string" },
            ],
          },
        ]
      end
    },
    Vendors__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, hint: "The current start cursor of the records returned.", type: "string" },
          { name: "next_cursor", optional: true, hint: "The next cursor to retrieve the next page of records.", type: "string" },
          { name: "per_page", optional: true, hint: "The maxumum number of records returned.", type: "integer" },
          { name: "estimated_remaining_count", optional: true, hint: "The number of remaining records including the returned records, up to a maximum of 500.", type: "integer" },
          {
            name: "filtered_by",
            optional: true,
            hint: "The filters applied to the returned record set.",
            type: "array",
            of: "object",
            properties: [
              { name: "name", optional: true, type: "object", properties: [{ name: "like", optional: true, type: "string" }, { name: "eq", optional: true, type: "string" }] },
              { name: "external_id", optional: true, type: "object", properties: [{ name: "eq", optional: false, type: "string" }] },
              { name: "created_at", optional: true, type: "object", properties: [{ name: "lt", optional: true, type: "string" }, { name: "lte", optional: true, type: "string" }, { name: "gt", optional: true, type: "string" }, { name: "gte", optional: true, type: "string" }] },
              { name: "updated_at", optional: true, type: "object", properties: [{ name: "lt", optional: true, type: "string" }, { name: "lte", optional: true, type: "string" }, { name: "gt", optional: true, type: "string" }, { name: "gte", optional: true, type: "string" }] },
            ]
          },
          {
            name: "sorted_by",
            optional: true,
            hint: "The sorts applied to the returned record set.",
            type: "array",
            of: "object",
            properties: [
              { name: "created_at", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
              { name: "updated_at", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
              { name: "id", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
            ]
          },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["VendorSummary"] }
        ]
      end
    },
    Vendor: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["VendorSummary"]
      end
    },
    VehicleSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: true, type: "integer" },
          { name: "account_id", optional: true, type: "integer" },
          { name: "archived_at", optional: true, hint: "The iso8601 date and time at which the vehicle was archived, for an archived vehicle.", type: "date_time" },
          { name: "fuel_type_id", optional: true, type: "integer" },
          { name: "fuel_type_name", optional: true, hint: "The name of the Fuel Type associated with this vehicle.", type: "string" },
          { name: "fuel_volume_units", optional: true, type: "string", pick_list: [["us_gallons", "us_gallons"], ["uk_gallons", "uk_gallons"], ["liters", "liters"]] },
          { name: "group_id", optional: true, type: "integer" },
          { name: "group_name", optional: true, hint: "The name of the Group associated with this vehicle, for vehicles associated with a group.", type: "string" },
          { name: "name", optional: true, hint: "This vehicle's name.", type: "string" },
          { name: "ownership", optional: true, type: "string", pick_list: [["owned", "owned"], ["leased", "leased"], ["rented", "rented"], ["customer", "customer"], ["financed", "financed"], ["rent_to_own", "rent_to_own"]] },
          { name: "vehicle_type_id", optional: true, hint: "This vehicles Vehicle Type id.", type: "integer" },
          { name: "vehicle_type_name", optional: true, hint: "The name of the Vehicle Type associated with this Vehicle.", type: "string" },
          { name: "vehicle_status_id", optional: true, hint: "The id of the Vehicle Status of this vehicle.", type: "integer" },
          { name: "vehicle_status_name", optional: true, hint: "The name of the Vehicle Status associated with this Vehicle.", type: "string" },
          { name: "vehicle_status_color", optional: true, hint: "The hex color code of the Vehicle Status associated with this Vehicle.", type: "string" },
          { name: "primary_meter_unit", optional: true, hint: "The measurement unit used for the Vehicle's primary, or secondary (if applicable), meter.", type: "string", pick_list: [["km", "km"], ["hr", "hr"], ["mi", "mi"]] },
          { name: "primary_meter_value", optional: true, hint: "The current value of the primary meter for this Vehicle.", type: "string" },
          { name: "primary_meter_date", optional: true, hint: "The date and time at which the primary meter was last updated.", type: "date_time" },
          { name: "secondary_meter_unit", optional: true, type: "string", pick_list: [["km", "km"], ["hr", "hr"], ["mi", "mi"]] },
          { name: "secondary_meter_value", optional: true, hint: "The current value of the secondary meter for this Vehicle.", type: "string" },
          { name: "secondary_meter_date", optional: true, hint: "The date and time at which the secondary meter was last updated.", type: "date_time" },
          { name: "in_service_meter_value", optional: true, hint: "The meter value at which this Vehicle was put into service.", type: "string" },
          { name: "in_service_date", optional: true, hint: "The date on which this Vehicle was put into service.", type: "date_time" },
          { name: "out_of_service_meter_value", optional: true, hint: "The meter value at which this Vehicle was or will be retired.", type: "string" },
          { name: "out_of_service_date", optional: true, hint: "The date on which this Vehicle was or will be retired.", type: "date_time" },
          { name: "fuel_entries_count", optional: true, hint: "The number of Fuel Entries associated with this Vehicle.", type: "integer" },
          { name: "service_entries_count", optional: true, hint: "The number of Service Entries associated with this Vehicle.", type: "integer" },
          { name: "issues_count", optional: true, hint: "The number of Issues this Vehicle is associated with.", type: "integer" },
          { name: "work_orders_count", optional: true, hint: "The number of Work Orders this Vehicle is associated with.", type: "integer" },
          {
            name: "labels",
            optional: true,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: true, type: "string" },
            ],
          },
          { name: "color", optional: true, hint: "The color of this Vehicle.", type: "string" },
          { name: "license_plate", optional: true, hint: "The license plate number of this Vehicle.", type: "string" },
          { name: "vin", optional: true, hint: "The Vehicle Identification Number of this Vehicle.", type: "string" },
          { name: "year", optional: true, hint: "This Vehicle's model year.", type: "string" },
          { name: "make", optional: true, hint: "The name of this Vehicle's manufacturer.", type: "string" },
          { name: "model", optional: true, hint: "The name of the model of this Vehicle.", type: "string" },
          { name: "trim", optional: true, hint: "The trim level of this Vehicle.", type: "string" },
          { name: "default_image_url_small", optional: true, hint: "The URL of a small-sized version of the default image for this Vehicle.", type: "string" },
          { name: "external_ids", optional: true, hint: "Any External IDs associated with this Vehicle.", type: "object" },
          { name: "custom_fields", optional: true, type: "object" },
          {
            name: "driver",
            optional: true,
            hint: "A Contact",
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "email", optional: true, hint: "The Contact's email address.", type: "string" },
              { name: "name", optional: true, hint: "The Contact's full name.", type: "string" },
              { name: "default_image_url", optional: true, hint: "The URL of the Contact's default image/profile photo, if any.", type: "string" },
            ],
          },
        ]
      end
    },
    Vehicles__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, hint: "The current start cursor of the records returned.", type: "string" },
          { name: "next_cursor", optional: true, hint: "The next cursor to retrieve the next page of records.", type: "string" },
          { name: "per_page", optional: true, hint: "The maxumum number of records returned.", type: "integer" },
          { name: "estimated_remaining_count", optional: true, hint: "The number of remaining records including the returned records, up to a maximum of 500.", type: "integer" },
          {
            name: "filtered_by",
            optional: true,
            hint: "The filters applied to the returned record set. If you have filtered by custom field filters, these will be returned with the respective like or eq filter value.",
            type: "array",
            of: "object",
            properties: [
              { name: "name", optional: true, type: "object", properties: [{ name: "like", optional: true, type: "string" }, { name: "eq", optional: true, type: "string" }] },
              { name: "vin", optional: true, type: "object", properties: [{ name: "like", optional: true, type: "string" }, { name: "eq", optional: true, type: "string" }] },
              { name: "license_plate", optional: true, type: "object", properties: [{ name: "like", optional: true, type: "string" }, { name: "eq", optional: true, type: "string" }] },
              { name: "external_id", optional: true, type: "object", properties: [{ name: "like", optional: false, type: "string" }] },
              { name: "labels", optional: true, type: "object", properties: [{ name: "include", optional: false, type: "string" }] },
              { name: "group_id", optional: true, type: "object", properties: [{ name: "eq", optional: false, type: "string" }] },
              { name: "vehicle_status_id", optional: true, type: "object", properties: [{ name: "eq", optional: false, type: "string" }] },
              { name: "vehicle_type_id", optional: true, type: "object", properties: [{ name: "eq", optional: false, type: "string" }] },
              { name: "created_at", optional: true, type: "object", properties: [{ name: "lt", optional: true, type: "string" }, { name: "lte", optional: true, type: "string" }, { name: "gt", optional: true, type: "string" }, { name: "gte", optional: true, type: "string" }] },
              { name: "updated_at", optional: true, type: "object", properties: [{ name: "lt", optional: true, type: "string" }, { name: "lte", optional: true, type: "string" }, { name: "gt", optional: true, type: "string" }, { name: "gte", optional: true, type: "string" }] },
            ]
          },
          {
            name: "sorted_by",
            optional: true,
            hint: "The sorts applied to the returned record set.",
            type: "array",
            of: "object",
            properties: [
              { name: "name", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
              { name: "created_at", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
              { name: "updated_at", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
              { name: "id", optional: true, type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]] },
            ]
          },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["VehicleSummary"] }
        ]
      end
    },
    VehicleTwo: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["VehicleSummary"] + [
          {
            name: "specs",
            optional: true,
            type: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "body_type", optional: true, hint: "The body type of the Vehicle, if available.", type: "string" },
              { name: "drive_type", optional: true, hint: "The drive type of the Vehicle, if available.", type: "string" },
              { name: "fuel_tank_capacity", optional: true, type: "number" },
              { name: "gross_vehicle_weight_rating", optional: true, type: "number" },
              { name: "engine_description", optional: true, type: "string" },
              { name: "transmission_description", optional: true, type: "string" },
              { name: "msrp", optional: true, hint: "Manufacturer's Suggested Retail Price (MSRP).", type: "string" },
            ],
          },
          {
            name: "current_location_entry",
            optional: true,
            hint: "The current location of the associated object.",
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "date", optional: true, type: "date_time" },
              { name: "address", optional: true, type: "string" },
              { name: "is_current", optional: true, type: "boolean" },
              {
                name: "geolocation",
                optional: true,
                type: "object",
                properties: [
                  { name: "latitude", optional: true, type: "number" },
                  { name: "longitude", optional: true, type: "number" },
                ],
              },
            ],
          },
        ]
      end
    },
    VehicleAssignmentSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "vehicle_id", optional: false, hint: "The id of the vehicle associated with this Vehicle Assignment.", type: "integer" },
          { name: "contact_id", optional: false, hint: "The id of the contact associated with this Vehicle Assignment.", type: "integer" },
          { name: "started_at", optional: false, hint: "The date and time of this Vehicle Assignment. Dates in the future are accepted. We recommend using ISO-8601 formatted dates to avoid ambiguity.", type: "date_time" },
          { name: "ended_at", optional: false, hint: "The date and time of this Vehicle Assignment ending. We recommend using ISO-8601 formatted dates to avoid ambiguity.", type: "date_time" },
          { name: "current", optional: false, hint: "Whether this Vehicle Assignment is current/active.", type: "boolean" },
          { name: "future", optional: false, hint: "Whether this Vehicle Assignment is set to take place in the future.", type: "boolean" },
          { name: "starting_meter_entry_value", optional: false, hint: "The meter value at the start of this Vehicle Assignment.", type: "number" },
          { name: "ending_meter_entry_value", optional: false, hint: "The meter value at the end of this Vehicle Assignment.", type: "number" },
          { name: "comments_count", optional: false, hint: "The number of comments on this Vehicle Assignment.", type: "integer" },
          {
            name: "contact",
            optional: false,
            hint: "A Contact",
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "name", optional: true, hint: "The Contact's full name.", type: "string" },
              { name: "default_image_url", optional: true, type: "string" },
            ],
          },
          {
            name: "vehicle",
            optional: false,
            hint: "A Vehicle",
            type: "object",
            properties: [
              { name: "id", optional: false, type: "integer" },
              { name: "name", optional: false, hint: "This vehicle's name.", type: "string" },
            ],
          },
        ]
      end
    },
    VehicleAssignments__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["VehicleAssignmentSummary"] }
        ]
      end
    },
    VehicleAssignment: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["VehicleAssignmentSummary"] + [
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
          { name: "custom_fields", optional: false, type: "object" },
        ]
      end
    },
    ServiceEntrySummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "completed_at", optional: false, hint: "The date and time at which the Service Entry was completed.", type: "date_time" },
          { name: "reference", optional: false, hint: "A reference number for this Service Entry.", type: "string" },
          { name: "started_at", optional: false, hint: "The date and time at which the Service Entry was started.", type: "date_time" },
          { name: "status", optional: false, hint: "The status of this Service Entry.", type: "string", pick_list: [["pending", "pending"], ["completed", "completed"]] },
          { name: "general_notes", optional: false, hint: "General notes for this Service Entry.", type: "string" },
          { name: "vehicle_id", optional: false, type: "integer" },
          { name: "vendor_id", optional: false, type: "integer" },
          { name: "work_order_id", optional: false, type: "integer" },
          { name: "is_sample", optional: false, hint: "Indicates whether or not this Service Entry is a sample. Sample Service Entries are not included in reports.", type: "boolean" },
          { name: "custom_fields", optional: true, type: "object" },
          {
            name: "labels",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: true, type: "string" },
            ],
          },
          { name: "labor_subtotal_cents", optional: true, hint: "The pre-tax subtotal amount for labor.", type: "integer" },
          { name: "parts_subtotal_cents", optional: true, hint: "The pre-tax subtotal amount for parts.", type: "integer" },
          { name: "subtotal_cents", optional: true, hint: "The pre-tax subtotal amount.", type: "integer" },
          { name: "total_amount_cents", optional: true, hint: "The total amount.", type: "integer" },
        ]
      end
    },
    ServiceEntries__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["ServiceEntrySummary"] }
        ]
      end
    },
    ServiceEntry: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["ServiceEntrySummary"] + [
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
          { name: "work_order_number", optional: false, hint: "The number of the Work Order this Service Entry is associated with.", type: "integer" },
          { name: "date", optional: false, hint: "The date of this Service Entry. Formatted according to ISO-8601 in User's local time.", type: "date_time" },
          {
            name: "service_entry_line_items",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "description", optional: false, hint: "A description of the service performed for this line item.", type: "string" },
              {
                name: "type",
                optional: false,
                hint: "Denotes the type of the ServiceEntryLineItem",
                type: "string",
                pick_list: [
                  ["ServiceEntryServiceTaskLineItem", "ServiceEntryServiceTaskLineItem"],
                  ["ServiceEntryLaborLineItem", "ServiceEntryLaborLineItem"],
                  ["ServiceEntryPartLineItem", "ServiceEntryPartLineItem"],
                  ["ServiceEntryTaxLineItem", "ServiceEntryTaxLineItem"],
                  ["ServiceEntryFeeLineItem", "ServiceEntryFeeLineItem"],
                  ["ServiceEntryTireLineItem", "ServiceEntryTireLineItem"],
                  ["ServiceEntryFreeTextLineItem", "ServiceEntryFreeTextLineItem"],
                ],
              },
              { name: "labor_cost", optional: true, type: "number" },
              { name: "parts_cost", optional: true, type: "number" },
              { name: "subtotal", optional: true, type: "number" },
            ],
          },
          { name: "discount", optional: true, type: "number" },
          { name: "tax_1", optional: true, type: "number" },
          { name: "tax_2", optional: true, type: "number" },
          { name: "subtotal", optional: true, type: "number" },
          { name: "total_amount", optional: true, type: "number" },
        ]
      end
    },
    PurchaseOrderSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "number", optional: false, hint: "The Purchase Order Number.", type: "integer" },
          { name: "description", optional: false, hint: "Open text field for Purchase Order description.", type: "string" },
          {
            name: "state",
            optional: false,
            hint: "See the Purchase Order Lifecycle Guide for more information about Purchase Order states and how to transition between them.",
            type: "string",
            pick_list: [
              ["draft", "draft"],
              ["submitted_for_approval", "submitted_for_approval"],
              ["rejected", "rejected"],
              ["approved", "approved"],
              ["purchased", "purchased"],
              ["received_partial", "received_partial"],
              ["received_full", "received_full"],
              ["closed", "closed"],
            ],
          },
          { name: "vendor_id", optional: false, hint: "The ID of the Vendor for this Purchase Order.", type: "integer" },
          { name: "subtotal_cents", optional: false, hint: "The subtotal for this Purchase Order in cents.", type: "integer" },
          { name: "shipping_cents", optional: false, hint: "The shipping amount for this Purchase Order in cents.", type: "integer" },
          { name: "total_amount_cents", optional: false, hint: "The total amount for this Purchase Order in cents.", type: "integer" },
          { name: "part_location_id", optional: false, hint: "The ID of the PartLocation associated with this Purchase Order.", type: "integer" },
          { name: "created_at", optional: false, type: "date_time" },
          { name: "updated_at", optional: false, type: "date_time" },
          { name: "custom_fields", optional: true, type: "object" },
          {
            name: "labels",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: true, type: "string" },
            ],
          },
        ]
      end
    },
    PurchaseOrders__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["PurchaseOrderSummary"] }
        ]
      end
    },
    PurchaseOrder: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["PurchaseOrderSummary"] + [
          {
            name: "purchase_order_line_items",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "part_id", optional: false, hint: "The Fleetio ID of the Part being purchased.", type: "integer" },
              { name: "quantity", optional: false, hint: "The quantity of this Part to be purchased.", type: "string" },
              { name: "unit_cost", optional: false, hint: "The cost of this Part (per unit).", type: "number" },
              { name: "subtotal", optional: true, hint: "The pre-tax subtotal amount.", type: "number" },
            ],
          },
          { name: "shipping", optional: true, type: "number" },
          { name: "subtotal", optional: true, type: "number" },
          { name: "total_amount", optional: true, type: "number" },
        ]
      end
    },
    PurchaseOrder_Created: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["PurchaseOrder"]
      end
    },
    PartSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "description", optional: false, hint: "A description of this Part.", type: "string" },
          { name: "manufacturer_part_number", optional: false, hint: "The part number from this Part's manufacturer.", type: "string" },
          { name: "number", optional: false, hint: "The part number being used for this Part within Fleetio.", type: "string" },
          { name: "part_category_id", optional: false, hint: "The id of the Part Category associated with this Part.", type: "integer" },
          { name: "part_manufacturer_id", optional: false, hint: "The id of the Part Manufacturer associated with this Part.", type: "integer" },
          { name: "upc", optional: false, hint: "The Universal Product Code for this Part.", type: "string" },
          { name: "unit_cost_cents", optional: false, hint: "The unit cost in cents for this Part.", type: "integer" },
          { name: "archived_at", optional: false, hint: "The date and time at which this Part was archived.", type: "date_time" },
          { name: "custom_fields", optional: true, type: "object" },
        ]
      end
    },
    Parts__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["PartSummary"] }
        ]
      end
    },
    Part_Created: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["PartSummary"] + [
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
          { name: "account_id", optional: false, type: "number" },
          { name: "total_quantity", optional: false, hint: "The total quantity on hand for this Part.", type: "number" },
        ]
      end
    },
    Part: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Part_Created"]
      end
    },
    InventoryJournalEntrySummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: true, type: "integer" },
          { name: "account_id", optional: false, type: "integer" },
          { name: "user_id", optional: false, hint: "The ID of the User associated with the entry.", type: "integer" },
          { name: "part_id", optional: false, hint: "The ID of the Part associated with the entry.", type: "integer" },
          { name: "part_location_detail_id", optional: false, hint: "The ID of the details of this Part at a specific Part Location. Not the same as part_location_id.", type: "integer" },
          { name: "previous_quantity", optional: false, hint: "The previous quantity of the Part before any adjustments.", type: "string" },
          { name: "current_quantity", optional: false, hint: "The current quantity of the Part after adjustments.", type: "string" },
          { name: "adjustment_quantity", optional: false, hint: "The quantity adjustment made to the Part's count.", type: "string" },
          {
            name: "adjustment_type",
            optional: false,
            hint: "The type of adjustment that triggered the entry.",
            type: "string",
            pick_list: [
              ["initial", "initial"],
              ["manual", "manual"],
              ["work_order", "work_order"],
              ["purchase_order", "purchase_order"],
              ["bulk_update", "bulk_update"],
              ["transfer", "transfer"],
              ["inspection_submission", "inspection_submission"],
              ["inspection_shortfall", "inspection_shortfall"],
            ],
          },
        ]
      end
    },
    InventoryJournalEntry: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["InventoryJournalEntrySummary"] + [
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
          { name: "vendor_id", optional: false, hint: "The ID of the Vendor associated with the entry. Only applicable if the entry is associated with a Purchase Order.", type: "integer" },
          { name: "work_order_id", optional: false, hint: "The ID of the Work Order associated with the entry. Only applicable if the entry is associated with a Work Order.", type: "integer" },
        ]
      end
    },
    InventoryJournalEntry_Created: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["InventoryJournalEntry"] + [
          { name: "unit_cost_cents", optional: true, hint: "The unit cost in cents of the Part associated with the entry.", type: "string" },
          { name: "total_inventory_value_cents", optional: true, hint: "The total inventory value in cents of the Part associated with the entry.", type: "string" },
        ]
      end
    },
    EquipmentSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "name", optional: false, hint: "The name for this Equipment.", type: "string" },
          { name: "brand", optional: false, hint: "The name of the brand which makes this Equipment.", type: "string" },
          { name: "model", optional: false, hint: "The model name of this Equipment.", type: "string" },
          { name: "serial_number", optional: false, hint: "The serial number of this Equipment.", type: "string" },
          { name: "equipment_type_id", optional: false, type: "integer" },
          { name: "type_name", optional: false, hint: "The name of the associated Equipment Type.", type: "string" },
          { name: "equipment_status_id", optional: false, type: "integer" },
          { name: "status_name", optional: false, hint: "The name of the associated Equipment Status.", type: "string" },
          { name: "group_id", optional: false, type: "integer" },
          { name: "archived_at", optional: false, hint: "The date and time at which the Equipment was archived.", type: "date_time" },
          { name: "custom_fields", optional: true, type: "object" },
        ]
      end
    },
    Equipment__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["EquipmentSummary"] }
        ]
      end
    },
    Equipment_Created: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["EquipmentSummary"] + [
          { name: "created_at", optional: false, type: "date_time" },
          { name: "updated_at", optional: false, type: "date_time" },
          { name: "account_id", optional: false, hint: "The ID of the Account this Equipment belongs to.", type: "integer" },
        ]
      end
    },
    Equipment: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Equipment_Created"]
      end
    },
    Equipment__Assignments__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["EquipmentEquipmentAssignmentSummary"] }
        ]
      end
    },
    Contacts__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, type: "string" },
          { name: "next_cursor", optional: true, type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["ContactSummary"] }
        ]
      end
    },
    Contacts__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "first_name_request_body", optional: false, control_type: "text", type: "string", original_name: "first_name", label: "first_name", location: "request_body" },
          { name: "middle_name_request_body", optional: true, control_type: "text", type: "string", original_name: "middle_name", label: "middle_name", location: "request_body" },
          { name: "last_name_request_body", optional: true, control_type: "text", type: "string", original_name: "last_name", label: "last_name", location: "request_body" },
          { name: "birth_date_request_body", optional: true, control_type: "date", type: "date", original_name: "birth_date", label: "birth_date", location: "request_body" },
          { name: "group_hierarchy_request_body", optional: true, hint: "A pipe delimited group hierarchy, e.g. 'Group 1|Group 2|Group 3'.", control_type: "text", type: "string", original_name: "group_hierarchy", label: "group_hierarchy", location: "request_body" },
          { name: "email_request_body", optional: true, control_type: "text", type: "string", original_name: "email", label: "email", location: "request_body" },
          { name: "mobile_phone_number_request_body", optional: true, control_type: "text", type: "string", original_name: "mobile_phone_number", label: "mobile_phone_number", location: "request_body" },
          { name: "home_phone_number_request_body", optional: true, control_type: "text", type: "string", original_name: "home_phone_number", label: "home_phone_number", location: "request_body" },
          { name: "work_phone_number_request_body", optional: true, control_type: "text", type: "string", original_name: "work_phone_number", label: "work_phone_number", location: "request_body" },
          { name: "street_address_request_body", optional: true, control_type: "text", type: "string", original_name: "street_address", label: "street_address", location: "request_body" },
          { name: "city_request_body", optional: true, control_type: "text", type: "string", original_name: "city", label: "city", location: "request_body" },
          { name: "region_request_body", optional: true, control_type: "text", type: "string", original_name: "region", label: "region", location: "request_body" },
          { name: "postal_code_request_body", optional: true, control_type: "text", type: "string", original_name: "postal_code", label: "postal_code", location: "request_body" },
          { name: "country_request_body", optional: true, control_type: "text", type: "string", original_name: "country", label: "country", location: "request_body" },
          { name: "employee_number_request_body", optional: true, hint: "Must be unique.", control_type: "text", type: "string", original_name: "employee_number", label: "employee_number", location: "request_body" },
          { name: "job_title_request_body", optional: true, control_type: "text", type: "string", original_name: "job_title", label: "job_title", location: "request_body" },
          { name: "start_date_request_body", optional: true, control_type: "date", type: "date", original_name: "start_date", label: "start_date", location: "request_body" },
          { name: "leave_date_request_body", optional: true, control_type: "date", type: "date", original_name: "leave_date", label: "leave_date", location: "request_body" },
          { name: "vehicle_operator_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "vehicle_operator", label: "vehicle_operator", location: "request_body" },
          { name: "license_number_request_body", optional: true, control_type: "text", type: "string", original_name: "license_number", label: "license_number", location: "request_body" },
          { name: "license_class_request_body", optional: true, control_type: "text", type: "string", original_name: "license_class", label: "license_class", location: "request_body" },
          { name: "license_state_request_body", optional: true, control_type: "text", type: "string", original_name: "license_state", label: "license_state", location: "request_body" },
          { name: "hourly_labor_rate_request_body", optional: true, control_type: "number", type: "number", original_name: "hourly_labor_rate", label: "hourly_labor_rate", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          { name: "group_id_request_body", optional: true, control_type: "number", type: "number", original_name: "group_id", label: "group_id", location: "request_body" },
          { name: "license_expiration_request_body", optional: true, control_type: "date", type: "date", original_name: "license_expiration", label: "license_expiration", location: "request_body" },
          { name: "employee_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "employee", label: "employee", location: "request_body" },
          { name: "technician_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "technician", label: "technician", location: "request_body" },
        ]
      end
    },
    Contacts__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", hint: "The start cursor for Keyset pagination.", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", hint: "The number of records per page to return", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_group_id__eq__query", hint: "Filter by Group id eq", control_type: "text", type: "string", original_name: "filter[group_id][eq]", label: "filter_group_id__eq_", location: "query" },
          { name: "filter_employee_number__eq__query", hint: "Filter by Employee number eq", control_type: "text", type: "string", original_name: "filter[employee_number][eq]", label: "filter_employee_number__eq_", location: "query" },
          { name: "sort_created_at__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[created_at]", label: "sort_created_at_", location: "query" },
          { name: "sort_id__query", default: "desc", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[id]", label: "sort_id_", location: "query" },
        ]
      end
    },
    Contacts__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }
        ]
      end
    },
    Contacts__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Contacts__Show_input"] + object_definitions["Contacts__Create_input"].map { |f| f.merge(optional: true) }
      end
    },
    Equipment__Assignments__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" },
          { name: "assignee_id_request_body", optional: false, control_type: "number", type: "number", original_name: "assignee_id", label: "assignee_id", location: "request_body" }
        ]
      end
    },
    Equipment__Assignments__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" },
          { name: "start_cursor_query", hint: "The start cursor for Keyset pagination.", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_contact_id__eq__query", hint: "Filter by Contact id eq", control_type: "text", type: "string", original_name: "filter[contact_id][eq]", label: "filter_contact_id__eq_", location: "query" },
        ]
      end
    },
    Equipment__Assignments__Unassign_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }
        ]
      end
    },
    Equipment__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "name_request_body", optional: false, hint: "The name for this Equipment.", control_type: "text", type: "string", original_name: "name", label: "name", location: "request_body" },
          { name: "brand_request_body", optional: true, control_type: "text", type: "string", original_name: "brand", label: "brand", location: "request_body" },
          { name: "model_request_body", optional: true, control_type: "text", type: "string", original_name: "model", label: "model", location: "request_body" },
          { name: "serial_number_request_body", optional: true, control_type: "text", type: "string", original_name: "serial_number", label: "serial_number", location: "request_body" },
          { name: "type_id_request_body", optional: false, control_type: "number", type: "number", original_name: "type_id", label: "type_id", location: "request_body" },
          { name: "status_id_request_body", optional: false, control_type: "number", type: "number", original_name: "status_id", label: "status_id", location: "request_body" },
          { name: "group_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "group_id", label: "group_id", location: "request_body" },
          { name: "purchase_vendor_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "purchase_vendor_id", label: "purchase_vendor_id", location: "request_body" },
          { name: "purchase_price_request_body", optional: true, control_type: "number", type: "number", original_name: "purchase_price", label: "purchase_price", location: "request_body" },
          { name: "purchase_date_request_body", optional: true, control_type: "date", type: "date", original_name: "purchase_date", label: "purchase_date", location: "request_body" },
          { name: "in_service_date_request_body", optional: true, control_type: "date", type: "date", original_name: "in_service_date", label: "in_service_date", location: "request_body" },
          { name: "linked_vehicle_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "linked_vehicle_id", label: "linked_vehicle_id", location: "request_body" },
          { name: "assignee_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "assignee_id", label: "assignee_id", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
        ]
      end
    },
    Equipment__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_labels__include__query", control_type: "text", type: "string", original_name: "filter[labels][include]", label: "filter_labels__include_", location: "query" },
          { name: "filter_group_id__eq__query", control_type: "text", type: "string", original_name: "filter[group_id][eq]", label: "filter_group_id__eq_", location: "query" },
        ]
      end
    },
    Equipment__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }
        ]
      end
    },
    Equipment__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Equipment__Show_input"] + object_definitions["Equipment__Create_input"].map { |f| f.merge(optional: true) }
      end
    },
    InventoryJournalEntries__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "adjustment_quantity_request_body", optional: true, control_type: "number", type: "number", original_name: "adjustment_quantity", label: "adjustment_quantity", location: "request_body" },
          { name: "inventory_adjustment_reason_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "inventory_adjustment_reason_id", label: "inventory_adjustment_reason_id", location: "request_body" },
          { name: "current_quantity_request_body", optional: true, control_type: "number", type: "number", original_name: "current_quantity", label: "current_quantity", location: "request_body" },
          { name: "part_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "part_id", label: "part_id", location: "request_body" },
          { name: "part_location_detail_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "part_location_detail_id", label: "part_location_detail_id", location: "request_body" },
        ]
      end
    },
    InventoryJournalEntries__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }
        ]
      end
    },
    Parts__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "description_request_body", optional: true, control_type: "text", type: "string", original_name: "description", label: "description", location: "request_body" },
          { name: "manufacturer_part_number_request_body", optional: true, control_type: "text", type: "string", original_name: "manufacturer_part_number", label: "manufacturer_part_number", location: "request_body" },
          { name: "measurement_unit_id_request_body", optional: true, control_type: "number", type: "number", original_name: "measurement_unit_id", label: "measurement_unit_id", location: "request_body" },
          { name: "number_request_body", optional: false, hint: "Must be unique.", control_type: "text", type: "string", original_name: "number", label: "number", location: "request_body" },
          { name: "part_category_id_request_body", optional: true, control_type: "number", type: "number", original_name: "part_category_id", label: "part_category_id", location: "request_body" },
          { name: "part_category_name_request_body", optional: true, control_type: "text", type: "string", original_name: "part_category_name", label: "part_category_name", location: "request_body" },
          { name: "part_manufacturer_id_request_body", optional: true, control_type: "number", type: "number", original_name: "part_manufacturer_id", label: "part_manufacturer_id", location: "request_body" },
          { name: "part_manufacturer_name_request_body", optional: true, control_type: "text", type: "string", original_name: "part_manufacturer_name", label: "part_manufacturer_name", location: "request_body" },
          { name: "unit_cost_request_body", optional: true, control_type: "number", type: "number", original_name: "unit_cost", label: "unit_cost", location: "request_body" },
          { name: "upc_request_body", optional: true, hint: "Must be unique.", control_type: "text", type: "string", original_name: "upc", label: "upc", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
        ]
      end
    },
    Parts__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_upc__eq__query", control_type: "text", type: "string", original_name: "filter[upc][eq]", label: "filter_upc__eq_", location: "query" },
          { name: "filter_part_category_id__eq__query", control_type: "text", type: "string", original_name: "filter[part_category_id][eq]", label: "filter_part_category_id__eq_", location: "query" },
        ]
      end
    },
    Parts__Update_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }] +
          object_definitions["Parts__Create_input"].map { |f| f.merge(optional: true) }
      end
    },
    PurchaseOrders__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "description_request_body", optional: true, control_type: "text", type: "string", original_name: "description", label: "description", location: "request_body" },
          { name: "label_list_request_body", optional: true, control_type: "text", type: "string", original_name: "label_list", label: "label_list", location: "request_body" },
          { name: "vendor_id_request_body", optional: true, control_type: "number", type: "number", original_name: "vendor_id", label: "vendor_id", location: "request_body" },
          { name: "part_location_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "part_location_id", label: "part_location_id", location: "request_body" },
          { name: "number_request_body", optional: false, control_type: "integer", type: "integer", original_name: "number", label: "number", location: "request_body" },
          { name: "discount_type_request_body", optional: true, control_type: "select", type: "string", pick_list: [["fixed", "fixed"], ["percentage", "percentage"]], original_name: "discount_type", label: "discount_type", location: "request_body" },
          { name: "discount_percentage_request_body", optional: true, control_type: "number", type: "number", original_name: "discount_percentage", label: "discount_percentage", location: "request_body" },
          { name: "shipping_request_body", optional: true, control_type: "number", type: "number", original_name: "shipping", label: "shipping", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          {
            name: "purchase_order_line_items_attributes_request_body",
            optional: true,
            of: "object",
            properties: [
              { name: "part_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "part_id", label: "part_id", location: "request_body" },
              { name: "quantity_request_body", optional: true, control_type: "integer", type: "integer", original_name: "quantity", label: "quantity", location: "request_body" },
              { name: "unit_cost_request_body", optional: true, control_type: "number", type: "number", original_name: "unit_cost", label: "unit_cost", location: "request_body" },
            ],
            type: "array",
            original_name: "purchase_order_line_items_attributes",
            label: "purchase_order_line_items_attributes",
            location: "request_body"
          },
        ]
      end
    },
    PurchaseOrders__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_vendor_id__eq__query", control_type: "text", type: "string", original_name: "filter[vendor_id][eq]", label: "filter_vendor_id__eq_", location: "query" },
          { name: "filter_state__include__query", control_type: "text", type: "string", original_name: "filter[state][include]", label: "filter_state__include_", location: "query" },
        ]
      end
    },
    PurchaseOrders__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "number_path", hint: "The Purchase Order Number", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "number", label: "number", location: "path" }]
      end
    },
    PurchaseOrders__Update_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "number_path", hint: "The Purchase Order Number", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "number", label: "number", location: "path" }] +
          object_definitions["PurchaseOrders__Create_input"].reject { |f| f[:name] == "number_request_body" }.map { |f| f.merge(optional: true) }
      end
    },
    ServiceEntries__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "completed_at_request_body", optional: false, control_type: "date_time", type: "date_time", original_name: "completed_at", label: "completed_at", location: "request_body" },
          { name: "started_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "started_at", label: "started_at", location: "request_body" },
          { name: "vehicle_id_request_body", optional: false, control_type: "number", type: "number", original_name: "vehicle_id", label: "vehicle_id", location: "request_body" },
          { name: "vendor_id_request_body", optional: true, control_type: "number", type: "number", original_name: "vendor_id", label: "vendor_id", location: "request_body" },
          { name: "reference_request_body", optional: true, control_type: "text", type: "string", original_name: "reference", label: "reference", location: "request_body" },
          { name: "label_list_request_body", optional: true, control_type: "text", type: "string", original_name: "label_list", label: "label_list", location: "request_body" },
          { name: "general_notes_request_body", optional: true, control_type: "text", type: "string", original_name: "general_notes", label: "general_notes", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          {
            name: "meter_entry_attributes_request_body",
            optional: false,
            hint: "A Service Entry may be associated with a Meter Entry",
            type: "object",
            properties: [
              { name: "value_request_body", optional: true, control_type: "number", type: "number", original_name: "value", label: "value", location: "request_body" },
              { name: "void_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "void", label: "void", location: "request_body" },
            ],
            original_name: "meter_entry_attributes",
            label: "meter_entry_attributes",
            location: "request_body"
          },
          {
            name: "service_entry_line_items_attributes_request_body",
            optional: true,
            of: "object",
            properties: [
              { name: "service_task_id_request_body", optional: true, control_type: "number", type: "number", original_name: "service_task_id", label: "service_task_id", location: "request_body" },
              { name: "type_request_body", optional: true, control_type: "select", type: "string", pick_list: [["ServiceEntryServiceTaskLineItem", "ServiceEntryServiceTaskLineItem"], ["ServiceEntryLaborLineItem", "ServiceEntryLaborLineItem"], ["ServiceEntryPartLineItem", "ServiceEntryPartLineItem"], ["ServiceEntryFeeLineItem", "ServiceEntryFeeLineItem"], ["ServiceEntryFreeTextLineItem", "ServiceEntryFreeTextLineItem"]], original_name: "type", label: "type", location: "request_body" },
              { name: "description_request_body", optional: true, control_type: "text", type: "string", original_name: "description", label: "description", location: "request_body" },
              { name: "labor_cost_request_body", optional: true, default: 0, control_type: "number", type: "number", original_name: "labor_cost", label: "labor_cost", location: "request_body" },
              { name: "parts_cost_request_body", optional: true, default: 0, control_type: "number", type: "number", original_name: "parts_cost", label: "parts_cost", location: "request_body" },
            ],
            type: "array",
            original_name: "service_entry_line_items_attributes",
            label: "service_entry_line_items_attributes",
            location: "request_body"
          },
          { name: "discount_request_body", optional: true, control_type: "number", type: "number", original_name: "discount", label: "discount", location: "request_body" },
          { name: "tax_1_request_body", optional: true, control_type: "number", type: "number", original_name: "tax_1", label: "tax_1", location: "request_body" },
          { name: "tax_2_request_body", optional: true, control_type: "number", type: "number", original_name: "tax_2", label: "tax_2", location: "request_body" },
          { name: "total_amount_request_body", optional: true, control_type: "number", type: "number", original_name: "total_amount", label: "total_amount", location: "request_body" },
        ]
      end
    },
    ServiceEntries__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_status__include__query", control_type: "text", type: "string", original_name: "filter[status][include]", label: "filter_status__include_", location: "query" },
          { name: "filter_labels__include__query", control_type: "text", type: "string", original_name: "filter[labels][include]", label: "filter_labels__include_", location: "query" },
        ]
      end
    },
    ServiceEntries__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    ServiceEntries__Update_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }] +
          object_definitions["ServiceEntries__Create_input"].reject { |f| f[:name] == "vehicle_id_request_body" || f[:name] == "meter_entry_attributes_request_body" }.map { |f| f.merge(optional: true) }
      end
    },
    VehicleAssignments__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "contact_id_request_body", optional: false, control_type: "number", type: "number", original_name: "contact_id", label: "contact_id", location: "request_body" },
          { name: "vehicle_id_request_body", optional: false, control_type: "number", type: "number", original_name: "vehicle_id", label: "vehicle_id", location: "request_body" },
          { name: "started_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "started_at", label: "started_at", location: "request_body" },
          { name: "ended_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "ended_at", label: "ended_at", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          {
            name: "starting_meter_entry_attributes_request_body",
            optional: true,
            type: "object",
            properties: [
              { name: "value_request_body", optional: true, control_type: "number", type: "number", original_name: "value", label: "value", location: "request_body" },
              { name: "void_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "void", label: "void", location: "request_body" },
            ],
            original_name: "starting_meter_entry_attributes",
            label: "starting_meter_entry_attributes",
            location: "request_body"
          },
        ]
      end
    },
    VehicleAssignments__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_contact_id__eq__query", control_type: "text", type: "string", original_name: "filter[contact_id][eq]", label: "filter_contact_id__eq_", location: "query" },
          { name: "filter_vehicle_id__eq__query", control_type: "text", type: "string", original_name: "filter[vehicle_id][eq]", label: "filter_vehicle_id__eq_", location: "query" },
        ]
      end
    },
    VehicleAssignments__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    VehicleAssignments__Unassign_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    Vehicles__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "name_request_body", optional: false, hint: "Must be unique.", control_type: "text", type: "string", original_name: "name", label: "name", location: "request_body" },
          { name: "color_request_body", optional: true, control_type: "text", type: "string", original_name: "color", label: "color", location: "request_body" },
          { name: "fuel_type_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "fuel_type_id", label: "fuel_type_id", location: "request_body" },
          { name: "group_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "group_id", label: "group_id", location: "request_body" },
          { name: "group_hierarchy_request_body", optional: true, control_type: "text", type: "string", original_name: "group_hierarchy", label: "group_hierarchy", location: "request_body" },
          { name: "label_ids_request_body", optional: true, of: "number", type: "array", original_name: "label_ids", label: "label_ids", location: "request_body" },
          { name: "license_plate_request_body", optional: true, control_type: "text", type: "string", original_name: "license_plate", label: "license_plate", location: "request_body" },
          { name: "make_request_body", optional: true, control_type: "text", type: "string", original_name: "make", label: "make", location: "request_body" },
          { name: "primary_meter_unit_request_body", optional: false, control_type: "select", type: "string", pick_list: [["km", "km"], ["hr", "hr"], ["mi", "mi"]], original_name: "primary_meter_unit", label: "primary_meter_unit", location: "request_body" },
          { name: "model_request_body", optional: true, control_type: "text", type: "string", original_name: "model", label: "model", location: "request_body" },
          { name: "ownership_request_body", optional: true, control_type: "select", type: "string", pick_list: [["owned", "owned"], ["leased", "leased"], ["rented", "rented"], ["customer", "customer"], ["financed", "financed"], ["rent_to_own", "rent_to_own"]], original_name: "ownership", label: "ownership", location: "request_body" },
          { name: "vehicle_status_id_request_body", optional: false, control_type: "integer", type: "integer", original_name: "vehicle_status_id", label: "vehicle_status_id", location: "request_body" },
          { name: "vehicle_type_id_request_body", optional: false, control_type: "integer", type: "integer", original_name: "vehicle_type_id", label: "vehicle_type_id", location: "request_body" },
          { name: "vin_request_body", optional: true, hint: "Must be unique.", control_type: "text", type: "string", original_name: "vin", label: "vin", location: "request_body" },
          { name: "year_request_body", optional: true, control_type: "integer", type: "integer", original_name: "year", label: "year", location: "request_body" },
          { name: "in_service_date_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "in_service_date", label: "in_service_date", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
        ]
      end
    },
    Vehicles__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_labels__include__query", control_type: "text", type: "string", original_name: "filter[labels][include]", label: "filter_labels__include_", location: "query" },
          { name: "filter_group_id__eq__query", control_type: "text", type: "string", original_name: "filter[group_id][eq]", label: "filter_group_id__eq_", location: "query" },
          { name: "filter_vehicle_status_id__eq__query", control_type: "text", type: "string", original_name: "filter[vehicle_status_id][eq]", label: "filter_vehicle_status_id__eq_", location: "query" },
        ]
      end
    },
    Vehicles__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", hint: "The Fleetio ID, VIN, license plate, or other external ID of the Vehicle.", optional: false, control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    Vehicles__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Vehicles__Show_input"] + object_definitions["Vehicles__Create_input"].reject { |f| f[:name] == "primary_meter_unit_request_body" }.map { |f| f.merge(optional: true) }
      end
    },
    Vendors__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "name_request_body", optional: false, hint: "Must be unique.", control_type: "text", type: "string", original_name: "name", label: "name", location: "request_body" },
          { name: "city_request_body", optional: true, control_type: "text", type: "string", original_name: "city", label: "city", location: "request_body" },
          { name: "contact_email_request_body", optional: true, control_type: "text", type: "string", original_name: "contact_email", label: "contact_email", location: "request_body" },
          { name: "contact_name_request_body", optional: true, control_type: "text", type: "string", original_name: "contact_name", label: "contact_name", location: "request_body" },
          { name: "contact_phone_request_body", optional: true, control_type: "text", type: "string", original_name: "contact_phone", label: "contact_phone", location: "request_body" },
          { name: "country_request_body", optional: true, control_type: "text", type: "string", original_name: "country", label: "country", location: "request_body" },
          { name: "external_id_request_body", optional: true, hint: "Must be unique.", control_type: "text", type: "string", original_name: "external_id", label: "external_id", location: "request_body" },
          { name: "phone_request_body", optional: true, control_type: "text", type: "string", original_name: "phone", label: "phone", location: "request_body" },
          { name: "postal_code_request_body", optional: true, control_type: "text", type: "string", original_name: "postal_code", label: "postal_code", location: "request_body" },
          { name: "region_request_body", optional: true, control_type: "text", type: "string", original_name: "region", label: "region", location: "request_body" },
          { name: "street_address_request_body", optional: true, control_type: "text", type: "string", original_name: "street_address", label: "street_address", location: "request_body" },
          { name: "website_request_body", optional: true, control_type: "text", type: "string", original_name: "website", label: "website", location: "request_body" },
          { name: "fuel_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "fuel", label: "fuel", location: "request_body" },
          { name: "service_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "service", label: "service", location: "request_body" },
          { name: "parts_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "parts", label: "parts", location: "request_body" },
          { name: "vehicle_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "vehicle", label: "vehicle", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
        ]
      end
    },
    Vendors__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_external_id__eq__query", control_type: "text", type: "string", original_name: "filter[external_id][eq]", label: "filter_external_id__eq_", location: "query" },
        ]
      end
    },
    Vendors__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    Vendors__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Vendors__Show_input"] + object_definitions["Vendors__Create_input"].map { |f| f.merge(optional: true) }
      end
    },
    WorkOrders__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_vehicle_id__eq__query", control_type: "text", type: "string", original_name: "filter[vehicle_id][eq]", label: "filter_vehicle_id__eq_", location: "query" },
          { name: "filter_vendor_id__eq__query", control_type: "text", type: "string", original_name: "filter[vendor_id][eq]", label: "filter_vendor_id__eq_", location: "query" },
          { name: "filter_number__eq__query", control_type: "text", type: "string", original_name: "filter[number][eq]", label: "filter_number__eq_", location: "query" },
          { name: "filter_work_order_status_name__include__query", control_type: "text", type: "string", original_name: "filter[work_order_status_name][include]", label: "filter_work_order_status_name__include_", location: "query" },
        ]
      end
    },
    WorkOrders__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    WorkOrders__Update_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" },
          { name: "issued_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "issued_at", label: "issued_at", location: "request_body" },
          { name: "started_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "started_at", label: "started_at", location: "request_body" },
          { name: "completed_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "completed_at", label: "completed_at", location: "request_body" },
          { name: "work_order_status_id_request_body", optional: true, control_type: "number", type: "number", original_name: "work_order_status_id", label: "work_order_status_id", location: "request_body" },
          { name: "invoice_number_request_body", optional: true, control_type: "text", type: "string", original_name: "invoice_number", label: "invoice_number", location: "request_body" },
          { name: "vendor_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "vendor_id", label: "vendor_id", location: "request_body" },
          { name: "vehicle_id_request_body", optional: true, control_type: "number", type: "number", original_name: "vehicle_id", label: "vehicle_id", location: "request_body" },
          { name: "contact_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "contact_id", label: "contact_id", location: "request_body" },
          { name: "label_list_request_body", optional: true, control_type: "text", type: "string", original_name: "label_list", label: "label_list", location: "request_body" },
          { name: "purchase_order_number_request_body", optional: true, control_type: "text", type: "string", original_name: "purchase_order_number", label: "purchase_order_number", location: "request_body" },
          { name: "description_request_body", optional: true, control_type: "text", type: "string", original_name: "description", label: "description", location: "request_body" },
          { name: "number_request_body", optional: true, control_type: "integer", type: "integer", original_name: "number", label: "number", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          { name: "scheduled_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "scheduled_at", label: "scheduled_at", location: "request_body" },
          { name: "expected_completed_at_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "expected_completed_at", label: "expected_completed_at", location: "request_body" },
          { name: "issue_ids_request_body", optional: true, of: "integer", type: "array", original_name: "issue_ids", label: "issue_ids", location: "request_body" },
          { name: "label_ids_request_body", optional: true, of: "integer", type: "array", original_name: "label_ids", label: "label_ids", location: "request_body" },
        ]
      end
    },
    IssueSummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "number", optional: false, hint: "A unique identifier for the Issue.", type: "string" },
          { name: "summary", optional: false, hint: "A short summary of the Issue.", type: "string" },
          { name: "description", optional: true, hint: "A longer description of the Issue.", type: "string" },
          { name: "state", optional: false, hint: "The Issue's current state.", type: "string", pick_list: [["Open", "Open"], ["Closed", "Closed"], ["Resolved", "Resolved"]] },
          { name: "asset_type", optional: false, hint: "The type of asset associated with the Issue.", type: "string", pick_list: [["Vehicle", "Vehicle"], ["Equipment", "Equipment"]] },
          { name: "vehicle_id", optional: true, type: "integer" },
          { name: "vehicle_name", optional: true, hint: "The name of the Vehicle associated with this Issue.", type: "string" },
          { name: "equipment_id", optional: true, type: "integer" },
          { name: "reported_by_id", optional: true, type: "integer" },
          { name: "reported_by_name", optional: true, hint: "The name of the Contact associated with the User who reported this Issue.", type: "string" },
          { name: "reported_at", optional: false, hint: "The date and time at which the issue was reported.", type: "date_time" },
          { name: "resolved_at", optional: true, type: "date_time" },
          { name: "closed_at", optional: true, type: "date_time" },
          { name: "reopened_at", optional: true, type: "date_time" },
          { name: "due_date", optional: true, hint: "The date on which this Issue should be resolved by. Formatted according to ISO-8601 in User's local time zone.", type: "date" },
          { name: "issue_priority_id", optional: true, type: "integer" },
          { name: "fault_id", optional: true, type: "integer" },
          { name: "overdue", optional: true, hint: "Indicates whether the Issue is overdue.", type: "boolean" },
          { name: "is_sample", optional: true, hint: "Indicates whether this Issue is sample data.", type: "boolean" },
          { name: "custom_fields", optional: true, type: "object" },
          { name: "watchers_count", optional: true, type: "integer" },
          { name: "comments_count", optional: true, type: "integer" },
          { name: "documents_count", optional: true, type: "integer" },
          { name: "images_count", optional: true, type: "integer" },
          {
            name: "labels",
            optional: true,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: true, type: "string" },
            ],
          },
          {
            name: "assigned_contacts",
            optional: true,
            hint: "An array of assigned Contacts related to the Issue.",
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "name", optional: true, hint: "The Contact's full name.", type: "string" },
              { name: "email", optional: true, type: "string" },
            ],
          },
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
        ]
      end
    },
    Issue: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["IssueSummary"] + [
          { name: "due_meter_value", optional: true, hint: "The meter value at which this Issue should be resolved by.", type: "string" },
          { name: "due_secondary_meter_value", optional: true, hint: "The secondary meter value at which this Issue should be resolved by.", type: "number" },
          {
            name: "meter_entry",
            optional: true,
            hint: "A Meter Entry",
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "value", optional: true, hint: "The current value of the meter.", type: "string" },
              { name: "void", optional: true, type: "boolean" },
              { name: "date", optional: true, type: "date" },
            ],
          },
          {
            name: "comments",
            optional: true,
            hint: "A list of the comments made on this record.",
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "user_full_name", optional: true, type: "string" },
              { name: "comment", optional: false, hint: "The content of the Comment message body.", type: "string" },
              { name: "created_at", optional: true, type: "date_time" },
            ],
          },
          {
            name: "documents",
            optional: true,
            hint: "A list of the documents attached to this record.",
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: false, type: "string" },
              { name: "file_url", optional: false, type: "string" },
            ],
          },
          {
            name: "images",
            optional: true,
            hint: "A list of the images attached to this record.",
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "file_url", optional: true, type: "string" },
              { name: "full_url", optional: true, type: "string" },
            ],
          },
        ]
      end
    },
    Issues__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, hint: "The current start cursor of the records returned.", type: "string" },
          { name: "next_cursor", optional: true, hint: "The next cursor to retrieve the next page of records.", type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["IssueSummary"] }
        ]
      end
    },
    Issues__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "asset_id_request_body", optional: false, hint: "The ID of the asset (Vehicle or Equipment) associated with the Issue.", control_type: "integer", type: "integer", original_name: "asset_id", label: "asset_id", location: "request_body" },
          { name: "asset_type_request_body", optional: false, control_type: "select", type: "string", pick_list: [["Vehicle", "Vehicle"], ["Equipment", "Equipment"]], original_name: "asset_type", label: "asset_type", location: "request_body" },
          { name: "summary_request_body", optional: false, hint: "A short summary of the Issue.", control_type: "text", type: "string", original_name: "summary", label: "summary", location: "request_body" },
          { name: "description_request_body", optional: true, hint: "A longer description of the Issue.", control_type: "text", type: "string", original_name: "description", label: "description", location: "request_body" },
          { name: "reported_by_id_request_body", optional: true, hint: "The id of the Contact who reported this Issue.", control_type: "integer", type: "integer", original_name: "reported_by_id", label: "reported_by_id", location: "request_body" },
          { name: "reported_at_request_body", optional: false, hint: "We recommend using ISO-8601 formatted dates to avoid ambiguity.", control_type: "date_time", type: "date_time", original_name: "reported_at", label: "reported_at", location: "request_body" },
          { name: "issue_priority_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "issue_priority_id", label: "issue_priority_id", location: "request_body" },
          { name: "number_request_body", optional: true, hint: "A unique identifier for the Issue.", control_type: "integer", type: "integer", original_name: "number", label: "number", location: "request_body" },
          { name: "due_date_request_body", optional: true, control_type: "date_time", type: "date_time", original_name: "due_date", label: "due_date", location: "request_body" },
          { name: "due_meter_value_request_body", optional: true, control_type: "number", type: "number", original_name: "due_meter_value", label: "due_meter_value", location: "request_body" },
          { name: "fault_id_request_body", optional: true, control_type: "integer", type: "integer", original_name: "fault_id", label: "fault_id", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
          { name: "assigned_contact_ids_request_body", optional: true, hint: "An array of ids of assigned Contacts related to the Issue.", of: "integer", type: "array", original_name: "assigned_contact_ids", label: "assigned_contact_ids", location: "request_body" },
          { name: "label_ids_request_body", optional: true, hint: "An array of Label IDs to apply to the Issue.", of: "integer", type: "array", original_name: "label_ids", label: "label_ids", location: "request_body" },
          {
            name: "comments_attributes_request_body",
            optional: true,
            of: "object",
            properties: [
              { name: "title_request_body", optional: true, control_type: "text", type: "string", original_name: "title", label: "title", location: "request_body" },
              { name: "comment_request_body", optional: true, control_type: "text", type: "string", original_name: "comment", label: "comment", location: "request_body" },
            ],
            type: "array",
            original_name: "comments_attributes",
            label: "comments_attributes",
            location: "request_body"
          },
        ]
      end
    },
    Issues__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", hint: "The start cursor for Keyset pagination.", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", hint: "The number of records per page to return", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_number__eq__query", hint: "Filter by Number eq", control_type: "text", type: "string", original_name: "filter[number][eq]", label: "filter_number__eq_", location: "query" },
          { name: "filter_reported_by_id__eq__query", hint: "Filter by Reported by id eq", control_type: "text", type: "string", original_name: "filter[reported_by_id][eq]", label: "filter_reported_by_id__eq_", location: "query" },
          { name: "filter_vehicle_id__eq__query", hint: "Filter by Vehicle id eq", control_type: "text", type: "string", original_name: "filter[vehicle_id][eq]", label: "filter_vehicle_id__eq_", location: "query" },
          { name: "filter_equipment_id__eq__query", hint: "Filter by Equipment id eq", control_type: "text", type: "string", original_name: "filter[equipment_id][eq]", label: "filter_equipment_id__eq_", location: "query" },
          { name: "filter_state__eq__query", hint: "Filter by State eq", control_type: "text", type: "string", original_name: "filter[state][eq]", label: "filter_state__eq_", location: "query" },
          { name: "filter_labels__include__query", hint: "Filter by Labels include", control_type: "text", type: "string", original_name: "filter[labels][include]", label: "filter_labels__include_", location: "query" },
          { name: "sort_due_date__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[due_date]", label: "sort_due_date_", location: "query" },
          { name: "sort_created_at__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[created_at]", label: "sort_created_at_", location: "query" },
          { name: "sort_updated_at__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[updated_at]", label: "sort_updated_at_", location: "query" },
          { name: "sort_id__query", default: "desc", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[id]", label: "sort_id_", location: "query" },
        ]
      end
    },
    Issues__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    Issues__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["Issues__Show_input"] +
          object_definitions["Issues__Create_input"].reject { |f| f[:name] == "reported_at_request_body" }.map { |f| f.merge(optional: true) }
      end
    },
    Issues__Close_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" },
          { name: "note_request_body", optional: false, hint: "A note to add to the Issue when it is closed.", control_type: "text", type: "string", original_name: "note", label: "note", location: "request_body" },
        ]
      end
    },
    Issues__Resolve_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" },
          { name: "note_request_body", optional: false, hint: "A note to add to the Issue when it is resolved.", control_type: "text", type: "string", original_name: "note", label: "note", location: "request_body" },
        ]
      end
    },
    Issues__Reopen_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    FuelEntrySummary: {
      fields: lambda do |_, _, _object_definitions|
        [
          { name: "id", optional: false, type: "integer" },
          { name: "external_id", optional: true, hint: "Used to uniquely identify Fuel Entries that are imported from external systems, such as Fleetcor and Wex.", type: "string" },
          { name: "vehicle_id", optional: true, type: "integer" },
          { name: "vendor_id", optional: true, type: "integer" },
          { name: "fuel_type_id", optional: true, type: "integer" },
          { name: "date", optional: false, hint: "The date and time at which this Fuel Entry was recorded.", type: "date_time" },
          { name: "partial", optional: true, hint: "Used to denote a partial fuel up as opposed to a complete fuel up.", type: "boolean" },
          { name: "personal", optional: true, hint: "Used to denote a personal expense.", type: "boolean" },
          { name: "reference", optional: true, hint: "Optional data field for collecting information such as the invoice number, transaction id, or receipt number.", type: "string" },
          { name: "us_gallons", optional: true, type: "string" },
          { name: "uk_gallons", optional: true, type: "string" },
          { name: "liters", optional: true, type: "string" },
          { name: "price_per_volume_unit", optional: true, hint: "The unit price for the Vehicle's volume unit.", type: "string" },
          { name: "total_amount_cents", optional: true, hint: "The total amount of the Fuel Entry in cents.", type: "integer" },
          { name: "is_sample", optional: true, type: "boolean" },
          { name: "images_count", optional: true, type: "integer" },
          { name: "documents_count", optional: true, type: "integer" },
          { name: "comments_count", optional: true, type: "integer" },
          { name: "watchers_count", optional: true, type: "integer" },
          { name: "custom_fields", optional: true, type: "object" },
          { name: "created_at", optional: true, type: "date_time" },
          { name: "updated_at", optional: true, type: "date_time" },
          {
            name: "vehicle",
            optional: true,
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "name", optional: true, hint: "This vehicle's name.", type: "string" },
            ],
          },
          {
            name: "vendor",
            optional: true,
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "name", optional: true, hint: "The name of the Vendor.", type: "string" },
            ],
          },
          {
            name: "meter_entry",
            optional: true,
            hint: "A Meter Entry",
            type: "object",
            properties: [
              { name: "id", optional: true, type: "integer" },
              { name: "value", optional: true, hint: "The current value of the meter.", type: "string" },
              { name: "void", optional: true, type: "boolean" },
              { name: "date", optional: true, type: "date" },
            ],
          },
        ]
      end
    },
    FuelEntry: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["FuelEntrySummary"] + [
          {
            name: "documents",
            optional: true,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "name", optional: false, type: "string" },
              { name: "file_url", optional: false, type: "string" },
            ],
          },
          {
            name: "images",
            optional: true,
            type: "array",
            of: "object",
            properties: [
              { name: "id", optional: true, type: "number" },
              { name: "file_url", optional: true, type: "string" },
              { name: "full_url", optional: true, type: "string" },
            ],
          },
        ]
      end
    },
    FuelEntries__Index_200_output: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor", optional: true, hint: "The current start cursor of the records returned.", type: "string" },
          { name: "next_cursor", optional: true, hint: "The next cursor to retrieve the next page of records.", type: "string" },
          { name: "per_page", optional: true, type: "integer" },
          { name: "estimated_remaining_count", optional: true, type: "integer" },
          { name: "records", optional: true, type: "array", of: "object", properties: object_definitions["FuelEntrySummary"] }
        ]
      end
    },
    FuelEntries__Create_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "vehicle_id_request_body", optional: false, control_type: "integer", type: "integer", original_name: "vehicle_id", label: "vehicle_id", location: "request_body" },
          { name: "vendor_id_request_body", optional: true, hint: "The Fleetio id of the Vendor associated with this Fuel Entry.", control_type: "integer", type: "integer", original_name: "vendor_id", label: "vendor_id", location: "request_body" },
          { name: "fuel_type_id_request_body", optional: true, hint: "The Fleetio id of the Fuel Type associated with this Fuel Entry.", control_type: "integer", type: "integer", original_name: "fuel_type_id", label: "fuel_type_id", location: "request_body" },
          { name: "date_request_body", optional: false, hint: "We recommend using ISO-8601 formatted dates to avoid ambiguity.", control_type: "date_time", type: "date_time", original_name: "date", label: "date", location: "request_body" },
          { name: "us_gallons_request_body", optional: true, hint: "The fuel volume amount in US gallons. Only used if the Vehicle is configured to use US gallons.", control_type: "number", type: "number", original_name: "us_gallons", label: "us_gallons", location: "request_body" },
          { name: "uk_gallons_request_body", optional: true, hint: "The fuel volume amount in UK gallons. Only used if the Vehicle is configured to use UK gallons.", control_type: "number", type: "number", original_name: "uk_gallons", label: "uk_gallons", location: "request_body" },
          { name: "liters_request_body", optional: true, hint: "The fuel volume amount in liters. Only used if the Vehicle is configured to use liters.", control_type: "number", type: "number", original_name: "liters", label: "liters", location: "request_body" },
          { name: "price_per_volume_unit_request_body", optional: true, hint: "The unit price for the Vehicle's configured volume unit.", control_type: "number", type: "number", original_name: "price_per_volume_unit", label: "price_per_volume_unit", location: "request_body" },
          {
            name: "meter_entry_attributes_request_body",
            optional: false,
            hint: "Each Fuel Entry requires an associated Meter Entry.",
            type: "object",
            properties: [
              { name: "value_request_body", optional: true, control_type: "number", type: "number", original_name: "value", label: "value", location: "request_body" },
              { name: "void_request_body", optional: true, control_type: "checkbox", type: "boolean", original_name: "void", label: "void", location: "request_body" },
            ],
            original_name: "meter_entry_attributes",
            label: "meter_entry_attributes",
            location: "request_body"
          },
          { name: "reference_request_body", optional: true, hint: "A reference number or identifier for this Fuel Entry, e.g. a receipt number.", control_type: "text", type: "string", original_name: "reference", label: "reference", location: "request_body" },
          { name: "partial_request_body", optional: true, hint: "Indicates whether this Fuel Entry is a partial fill-up. Defaults to false.", control_type: "checkbox", type: "boolean", original_name: "partial", label: "partial", location: "request_body" },
          { name: "personal_request_body", optional: true, hint: "Indicates whether this Fuel Entry is personal. Defaults to false.", control_type: "checkbox", type: "boolean", original_name: "personal", label: "personal", location: "request_body" },
          { name: "custom_fields_request_body", optional: true, type: "object", original_name: "custom_fields", label: "custom_fields", location: "request_body" },
        ]
      end
    },
    FuelEntries__Index_input: {
      fields: lambda do |_, _, object_definitions|
        [
          { name: "start_cursor_query", hint: "The start cursor for Keyset pagination.", control_type: "text", type: "string", original_name: "start_cursor", label: "start_cursor", location: "query" },
          { name: "per_page_query", hint: "The number of records per page to return.", minimum: 2, maximum: 100, default: 50, control_type: "integer", type: "integer", original_name: "per_page", label: "per_page", location: "query" },
          { name: "filter_external_id__eq__query", hint: "Filter by External id eq", control_type: "text", type: "string", original_name: "filter[external_id][eq]", label: "filter_external_id__eq_", location: "query" },
          { name: "filter_vehicle_id__eq__query", hint: "Filter by Vehicle id eq", control_type: "text", type: "string", original_name: "filter[vehicle_id][eq]", label: "filter_vehicle_id__eq_", location: "query" },
          { name: "filter_vendor_id__eq__query", hint: "Filter by Vendor id eq", control_type: "text", type: "string", original_name: "filter[vendor_id][eq]", label: "filter_vendor_id__eq_", location: "query" },
          { name: "sort_date__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[date]", label: "sort_date_", location: "query" },
          { name: "sort_created_at__query", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[created_at]", label: "sort_created_at_", location: "query" },
          { name: "sort_id__query", default: "desc", control_type: "select", type: "string", pick_list: [["asc", "asc"], ["desc", "desc"]], original_name: "sort[id]", label: "sort_id_", location: "query" },
        ]
      end
    },
    FuelEntries__Show_input: {
      fields: lambda do |_, _, object_definitions|
        [{ name: "id_path", hint: "The id of the relevant record", optional: false, pattern: "^[0-9]+$", control_type: "text", type: "string", original_name: "id", label: "id", location: "path" }]
      end
    },
    FuelEntries__Update_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions["FuelEntries__Show_input"] +
          object_definitions["FuelEntries__Create_input"].reject { |f| f[:name] == "vehicle_id_request_body" || f[:name] == "meter_entry_attributes_request_body" }.map { |f| f.merge(optional: true) }
      end
    }
  },

  methods: {
    format_api_request: lambda do |input, input_schema|
      request_payload = {}

      actual_input = call(:transform_keys_to_original_name, input_schema, input)
      input_with_location = call(:add_location_to_input, input_schema, actual_input)

      actual_input.each do |original_name, data|
        stored_values = request_payload[data[:location]] || {}
        request_payload[data[:location]] = stored_values.merge(original_name => data[:value])
      end

      # Format cookies into semicolon separated string and add to headers
      if request_payload["cookie"]
        request_payload["cookie"] = call(:format_cookies, request_payload["cookie"])
        request_payload["header"] = (request_payload["header"] || {}).deep_merge({ "Cookie" => request_payload["cookie"]} )
      end

      request_payload
    end,
    format_cookies: lambda do |cookies|
      cookie_string = []
      cookies.map do |key, value|
        cookie_string = cookie_string.concat(["#{key}=#{value}"])
      end
      cookie_string.smart_join("; ")
    end,
    format_url_endpoint: lambda do |request_payload, url|
      final_url = url
      if request_payload["path"].present?
        request_payload["path"].map do |key,value|
          final_url = final_url.gsub("{#{key}}",value)
        end
      end
      final_url
    end,
    clear_name: lambda do |data|
      hash_data = { root: data }
      call('recursive_clear_name!', hash_data)[:root]
    end,
    recursive_clear_name!: lambda do |hash_data|
      hash_data.clone.each do |_key, value|
        if value.is_a?(Hash)
          call('recursive_clear_name!', value)
        elsif value.is_a?(Array) && value.first.is_a?(Hash)
          value.map { |v| call('recursive_clear_name!', v) }
        elsif hash_data[:name]&.to_s =~ /W/
          hash_data[:name] = hash_data[:name]&.to_s&.gsub(/W/, '_')
        end
      end
    end,
    transform_keys_to_original_name: lambda do |input_schema, input|
      transformed_hash = {}
      input.each do |key, value|
        source_input = element = call(:recursively_find_hash_by_name, input_schema, key)
        new_key = source_input[:original_name]

        if value.is_a?(Hash)
          transformed_hash[new_key] = call(:transform_keys_to_original_name, input_schema, value)
        elsif value.is_a?(Array)
          transformed_hash[new_key] = value.map { |item| item.is_a?(Hash) ? call(:transform_keys_to_original_name, input_schema, item) : item }
        else
          transformed_hash[new_key] = value
        end
      end

      transformed_hash
    end,
    add_location_to_input: lambda do |input_schema, actual_input|
      actual_input.each do |key, value|
        source_input = call(:recursively_find_hash_by_original_name, input_schema, key)
        location = source_input[:location]

        actual_input[key] = { location: location, value: value }
      end

      actual_input
    end,
    recursively_find_hash_by_name: lambda do |input_schema, name|
      if input_schema.is_a?(Hash) && input_schema['name'] == name
        input_schema
      elsif input_schema.is_a?(Hash)
        input_schema.values.map { |x| call(:recursively_find_hash_by_name, x, name) }.compact.first
      elsif input_schema.is_a?(Array)
        input_schema.map { |x| call(:recursively_find_hash_by_name, x, name) }.compact.first
      end
    end,
    recursively_find_hash_by_original_name: lambda do |input_schema, name|
      if input_schema.is_a?(Hash) && input_schema['original_name'] == name
        input_schema
      elsif input_schema.is_a?(Hash)
        input_schema.values.map { |x| call(:recursively_find_hash_by_original_name, x, name) }.compact.first
      elsif input_schema.is_a?(Array)
        input_schema.map { |x| call(:recursively_find_hash_by_original_name, x, name) }.compact.first
      end
    end,
    Contacts__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/contacts"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.params(request_payload['query'] || {}).payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Contacts__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/contacts"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Contacts__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/contacts/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Contacts__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/contacts/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Equipment__Assignments__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment/{id}/assignments"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Equipment__Assignments__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment/{id}/assignments"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Equipment__Assignments__Unassign_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment/{id}/assignments/unassign"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Equipment__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Equipment__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Equipment__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Equipment__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/equipment/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    FuelEntries__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/fuel_entries"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    FuelEntries__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/fuel_entries"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    FuelEntries__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/fuel_entries/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    FuelEntries__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/fuel_entries/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    InventoryJournalEntries__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/inventory_journal_entries"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    InventoryJournalEntries__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/inventory_journal_entries/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Issues__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Issues__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Issues__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Issues__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Issues__Close_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues/{id}/close"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      put(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Issues__Resolve_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues/{id}/resolve"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      put(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Issues__Reopen_execute: lambda do |connection, input, extended_input_schema|
      url = "api/issues/{id}/reopen"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      put(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Parts__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/parts"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Parts__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/parts"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Parts__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/parts/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    PurchaseOrders__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/purchase_orders"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    PurchaseOrders__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/purchase_orders"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    PurchaseOrders__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/purchase_orders/{number}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    PurchaseOrders__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/purchase_orders/{number}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    ServiceEntries__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/service_entries"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    ServiceEntries__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/service_entries"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    ServiceEntries__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/service_entries/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    ServiceEntries__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/service_entries/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    VehicleAssignments__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicle_assignments"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    VehicleAssignments__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicle_assignments"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    VehicleAssignments__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicle_assignments/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    VehicleAssignments__Unassign_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicle_assignments/{id}/unassign"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Vehicles__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicles"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Vehicles__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicles"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Vehicles__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicles/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Vehicles__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vehicles/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Vendors__Create_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vendors"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      post(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    Vendors__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vendors"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    Vendors__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vendors/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    Vendors__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/vendors/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end,
    WorkOrders__Index_execute: lambda do |connection, input, extended_input_schema|
      url = "api/work_orders"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.params(request_payload['query'] || {}).headers(request_payload['header'] || {})
    end,
    WorkOrders__Show_execute: lambda do |connection, input, extended_input_schema|
      url = "api/work_orders/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      get(url).request_format_json.headers(request_payload['header'] || {})
    end,
    WorkOrders__Update_execute: lambda do |connection, input, extended_input_schema|
      url = "api/work_orders/{id}"
      request_payload = call('format_api_request', input, extended_input_schema)
      url = call('format_url_endpoint', request_payload, url)
      patch(url).request_format_json.payload(request_payload['request_body'] || {}).headers(request_payload['header'] || {})
    end
  },

  pick_lists: {
    fleetio_webhook_events: lambda do
      [
        ['Contact archived', 'contact_archived'],
        ['Contact assigned', 'contact_assigned'],
        ['Contact comment added', 'contact_comment_added'],
        ['Contact created', 'contact_created'],
        ['Contact deleted', 'contact_deleted'],
        ['Contact merged', 'contact_merged'],
        ['Contact updated', 'contact_updated'],
        ['Equipment comment added', 'equipment_comment_added'],
        ['Equipment created', 'equipment_created'],
        ['Equipment deleted', 'equipment_deleted'],
        ['Equipment updated', 'equipment_updated'],
        ['Expense entry comment added', 'expense_entry_comment_added'],
        ['Expense entry created', 'expense_entry_created'],
        ['Expense entry deleted', 'expense_entry_deleted'],
        ['Expense entry updated', 'expense_entry_updated'],
        ['Fault created', 'fault_created'],
        ['Fault resolved', 'fault_resolved'],
        ['Fuel entry comment added', 'fuel_entry_comment_added'],
        ['Fuel entry created', 'fuel_entry_created'],
        ['Fuel entry deleted', 'fuel_entry_deleted'],
        ['Fuel entry updated', 'fuel_entry_updated'],
        ['Import completed', 'import_completed'],
        ['Issue closed', 'issue_closed'],
        ['Issue comment added', 'issue_comment_added'],
        ['Issue created', 'issue_created'],
        ['Issue deleted', 'issue_deleted'],
        ['Issue resolved', 'issue_resolved'],
        ['Issue updated', 'issue_updated'],
        ['Location entry created', 'location_entry_created'],
        ['Location entry deleted', 'location_entry_deleted'],
        ['Location entry updated', 'location_entry_updated'],
        ['Meter entry created', 'meter_entry_created'],
        ['Meter entry deleted', 'meter_entry_deleted'],
        ['Meter entry updated', 'meter_entry_updated'],
        ['Part comment added', 'part_comment_added'],
        ['Part created', 'part_created'],
        ['Part deleted', 'part_deleted'],
        ['Part updated', 'part_updated'],
        ['Place created', 'place_created'],
        ['Place deleted', 'place_deleted'],
        ['Place updated', 'place_updated'],
        ['Place visited', 'place_visited'],
        ['Purchase order approved', 'purchase_order_approved'],
        ['Purchase order closed', 'purchase_order_closed'],
        ['Purchase order comment added', 'purchase_order_comment_added'],
        ['Purchase order created', 'purchase_order_created'],
        ['Purchase order deleted', 'purchase_order_deleted'],
        ['Purchase order pending approval', 'purchase_order_pending_approval'],
        ['Purchase order purchased', 'purchase_order_purchased'],
        ['Purchase order received', 'purchase_order_received'],
        ['Purchase order updated', 'purchase_order_updated'],
        ['Service entry comment added', 'service_entry_comment_added'],
        ['Service entry created', 'service_entry_created'],
        ['Service entry deleted', 'service_entry_deleted'],
        ['Service entry updated', 'service_entry_updated'],
        ['Submitted inspection form created', 'submitted_inspection_form_created'],
        ['Submitted inspection form deleted', 'submitted_inspection_form_deleted'],
        ['User archived', 'user_archived'],
        ['User created', 'user_created'],
        ['User updated', 'user_updated'],
        ['Vehicle archived', 'vehicle_archived'],
        ['Vehicle assigned', 'vehicle_assigned'],
        ['Vehicle assignment created', 'vehicle_assignment_created'],
        ['Vehicle assignment deleted', 'vehicle_assignment_deleted'],
        ['Vehicle assignment updated', 'vehicle_assignment_updated'],
        ['Vehicle comment added', 'vehicle_comment_added'],
        ['Vehicle created', 'vehicle_created'],
        ['Vehicle deleted', 'vehicle_deleted'],
        ['Vehicle group changed', 'vehicle_group_changed'],
        ['Vehicle status changed', 'vehicle_status_changed'],
        ['Vehicle updated', 'vehicle_updated'],
        ['Vendor comment added', 'vendor_comment_added'],
        ['Vendor created', 'vendor_created'],
        ['Vendor deleted', 'vendor_deleted'],
        ['Vendor updated', 'vendor_updated'],
        ['Work order comment added', 'work_order_comment_added'],
        ['Work order created', 'work_order_created'],
        ['Work order deleted', 'work_order_deleted'],
        ['Work order document added', 'work_order_document_added'],
        ['Work order status changed', 'work_order_status_changed'],
        ['Work order updated', 'work_order_updated']
      ]
    end
  }
}
