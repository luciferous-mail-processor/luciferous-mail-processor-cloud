from aws_lambda_powertools.utilities.data_classes import SQSEvent, event_source

from utils.logger import create_logger, logging_function, logging_handler

logger = create_logger(__name__)


@event_source(data_class=SQSEvent)
@logging_handler(logger)
def handler(event: SQSEvent, context):
    main(event=event)


@logging_function(logger)
def main(*, event: SQSEvent):
    pass
