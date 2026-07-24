from airflow.sdk import dag, task
from src.elt.load import load_data
import pendulum


@task
def load():
    load_data()


@dag(
    dag_id= "producer_dag",
    schedule= "@hourly",
    start_date = pendulum.datetime(2026, 7, 24),
    catchup= False,
    is_paused_upon_creation= False,
)
def producer_dag():
    
    load()


producer_dag()
