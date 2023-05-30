from PythonEDA.event import Event
from PythonEDAInfrastructure.network.grpc.server import GrpcServer
from PythonEDAPythonPackages.python_package_requested import PythonPackageRequested

import logging

class PythonPackagesGrpcServer(GrpcServer):

    async def PythonPackageRequestedNotifications(self, request, context):
        logging.getLogger(__name__).debug(f'Received "{request}", "{context}"')
#        response = python_package_requested_pb2.Reply(code=200)
        event = self.build_python_package_requested(request)
        await self.app.accept(event)
        return response

    async def add_servicers(self, server, app):
        # TODO: python_package_requested_pb2_grpc.add_PythonPackageRequestedServiceServicer_to_server(self, server)
        pass
#
    def build_python_package_requested(self, request) -> Event:
        return PythonPackageRequested(request.package_name, request.package_version)
