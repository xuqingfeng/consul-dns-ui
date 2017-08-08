<template>
    <div id="app" class="container">
        <h1>consul-dns-ui</h1>

        <p>use consul purely as a dns server</p>

        <div class="alert alert-info">
        </div>

        <h2>Edit Service</h2>

        <div class="grid">
            <div class="cell -3of12"></div>
            <div class="cell -6of12">
                <form class="form">
                    <fieldset class="form-group">
                        <label for="id">ID:</label>
                        <input id="id" type="text" class="form-control" required v-model="serviceFocused.ID">
                        <label for="name">Name:</label>
                        <input id="name" type="text" class="form-control" required v-model="serviceFocused.Name">
                    </fieldset>
                    <fieldset class="form-group">
                        <label for="address">Address:</label>
                        <input id="address" type="text" class="form-control" required v-model="serviceFocused.Address">
                        <label for="port">Port:</label>
                        <input id="port" type="number" class="form-control" required v-model="serviceFocused.Port">
                    </fieldset>
                    <div class="form-actions">
                        <button type="button" class="btn btn-primary btn-block" v-on:click="putService">Submit</button>
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
                <td><a v-on:click="focus(s.ID)">{{ s.ID }}</a></td>
                <td>{{ s.Service }}</td>
                <td>{{ s.Address }}</td>
                <td>{{ s.Port }}</td>
                <td>{{ s.DNS }}</td>
                <td>
                    <button class="btn btn-default btn-block" v-on:click="deRegisterService(s.ID)">x</button>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</template>

<script>

    // for dev
    var consul_address = process.env.CONSUL_ADDRESS || '127.0.0.1:8500';
    var consul_domain_suffix = process.env.CONSUL_DOMAIN_SUFFIX || 'internal';

    // log env vars
    console.info('CONSUL_ADDRESS: ' + consul_address);
    console.info('CONSUL_DOMAIN_SUFFIX: ' + consul_domain_suffix);

    export default {
        name: 'app',
        data() {
            return {
                services: {},
                serviceFocused: {ID: "", Name: "", Address: "", Port: null}
            }
        },
        mounted() {
            this.getServices();
        },
        methods: {
            getServices(){
                this.$http.get('http://' + consul_address + '/v1/agent/services').then(response => {
                    this.services = response.body;
                    // concatenate dns
                    for (var s in this.services) {
                        if (this.services.hasOwnProperty(s)) {
                            this.services[s].DNS = this.services[s].Service + '.service.' + consul_domain_suffix;
                        }
                    }
                }, response => {
                    console.error(response.statusText);
                })
            },
            putService(){
                if (this.serviceFocused.Port > 0) {
                    var params = {
                        ID: this.serviceFocused.ID,
                        Name: this.serviceFocused.Name,
                        Address: this.serviceFocused.Address,
                        Port: parseInt(this.serviceFocused.Port)
                    };

                    // FIXME: https://github.com/hashicorp/consul/issues/865
                    this.$http.put('http://' + consul_address + '/v1/agent/service/register', params).then(response => {
                        params.DNS = params.Name + '.service.' + consul_domain_suffix;
                        this.services[params.ID] = params;

                        // test
                        this.services['test'] = {ID: "test", Name: "test", Address: "1.2.3.4", Port: 3000, DNS: "test.com"};
                    }, response => {
                        console.error(response.statusText);
                    })
                } else {
                    console.error('Invalid port: ' + this.serviceFocused.Port);
                }
            },
            deRegisterService(id){
                this.$http.put('http://' + consul_address + '/v1/agent/service/deregister/' + id).then(response => {
                    delete this.services[id];
                }, response => {
                    console.error(response.statusText);
                })
            },
            focus(id){
                this.serviceFocused = {
                    ID: this.services[id].ID,
                    Name: this.services[id].Service,
                    Address: this.services[id].Address,
                    Port: this.services[id].Port
                };
            }
        }
    }

</script>

<style>
    @import '../node_modules/hack/dist/hack.css';
    @import '../node_modules/hack/dist/standard.css';
</style>