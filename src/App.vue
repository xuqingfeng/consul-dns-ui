<script>
var consul_address = import.meta.env.CONSUL_ADDRESS || "127.0.0.1:8500";
var consul_domain_suffix = import.meta.env.CONSUL_DOMAIN_SUFFIX || "internal";

// log env vars
console.info("CONSUL_ADDRESS: " + consul_address);
console.info("CONSUL_DOMAIN_SUFFIX: " + consul_domain_suffix);

export default {
  name: "app",
  data() {
    return {
      services: {},
      serviceFocused: { ID: "", Name: "", Address: "", Port: null },
    };
  },
  mounted() {
    this.getServices();
  },
  methods: {
    getServices() {
      fetch("http://" + consul_address + "/v1/agent/services").then(
        async (response) => {
          const data = await response.json();

          if (!response.ok) {
            const err = data || response.statusText;
            console.error(err);
            return Promise.reject(err);
          }
          this.services = data;
          // concatenate dns
          for (var s in this.services) {
            if (this.services.hasOwnProperty(s)) {
              this.services[s].DNS =
                this.services[s].Service + ".service." + consul_domain_suffix;
            }
          }
        }
      );
    },
    putService() {
      if (this.serviceFocused.Port > 0) {
        var params = {
          ID: this.serviceFocused.ID,
          Name: this.serviceFocused.Name,
          Address: this.serviceFocused.Address,
          Port: parseInt(this.serviceFocused.Port),
        };

        var requestOptions = {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(params),
        };
        fetch(
          "http://" + consul_address + "/v1/agent/service/register",
          requestOptions
        ).then(async (response) => {
          if (!response.ok) {
            const err = response.statusText;
            console.error(err);
            return Promise.reject(response);
          }
          params.Service = params.Name;
          params.DNS = params.Name + ".service." + consul_domain_suffix;
          this.services[params.ID] = params;
          this.$forceUpdate();
        });
      } else {
        console.error("Invalid port: " + this.serviceFocused.Port);
      }
    },
    deRegisterService(id) {
      var requestOptions = {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
      };
      fetch(
        "http://" + consul_address + "/v1/agent/service/deregister/" + id,
        requestOptions
      ).then(async (response) => {
        if (!response.ok) {
          console.error(response.statusText);
          return Promise.reject(response.statusText);
        }
        delete this.services[id];
        this.$forceUpdate();
      });
    },
    focus(id) {
      this.serviceFocused = {
        ID: this.services[id].ID,
        Name: this.services[id].Service,
        Address: this.services[id].Address,
        Port: this.services[id].Port,
      };
    },
  },
};
</script>

<template>
  <div id="app" class="container">
    <h1>consul-dns-ui</h1>

    <p>use consul purely as a dns server</p>

    <h2>Edit Service</h2>

    <div class="grid">
      <div class="cell -3of12"></div>
      <div class="cell -6of12">
        <form class="form">
          <fieldset class="form-group">
            <label for="id">ID:</label>
            <input
              id="id"
              type="text"
              class="form-control"
              required
              v-model="serviceFocused.ID"
            />
            <label for="name">Name:</label>
            <input
              id="name"
              type="text"
              class="form-control"
              required
              v-model="serviceFocused.Name"
            />
          </fieldset>
          <fieldset class="form-group">
            <label for="address">Address:</label>
            <input
              id="address"
              type="text"
              class="form-control"
              required
              v-model="serviceFocused.Address"
            />
            <label for="port">Port:</label>
            <input
              id="port"
              type="number"
              class="form-control"
              required
              v-model="serviceFocused.Port"
            />
          </fieldset>
          <div class="form-actions">
            <button
              type="button"
              class="btn btn-primary btn-block"
              v-on:click="putService"
            >
              Submit
            </button>
          </div>
        </form>
      </div>
      <div class="cell -6of12"></div>
    </div>

    <h2>Services</h2>

    <table>
      <thead>
        <th>ID</th>
        <th>Service</th>
        <th>Address</th>
        <th>Port</th>
        <th>DNS</th>
        <th>DeRegister</th>
      </thead>
      <tbody>
        <tr v-for="s in services">
          <td>
            <a v-on:click="focus(s.ID)">{{ s.ID }}</a>
          </td>
          <td>{{ s.Service }}</td>
          <td>{{ s.Address }}</td>
          <td>{{ s.Port }}</td>
          <td>{{ s.DNS }}</td>
          <td>
            <button
              class="btn btn-default btn-block"
              v-on:click="deRegisterService(s.ID)"
            >
              x
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script></script>
