from locust import HttpUser, task, events, between
from locust_plugins import jmeter_listener

class MyUser(HttpUser):

    @task(2)
    def index(self):
       self.client.get("/")
       
    wait_time = between(0.5, 3)

@events.init.add_listener
def on_locust_init(environment, **_kwargs):
    jmeter_listener.JmeterListener(env=environment, testplan="examplePlan")