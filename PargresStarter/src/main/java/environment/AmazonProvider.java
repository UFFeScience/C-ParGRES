package environment;

import adaptability.VirtualMachineType;
import main.XMLReader;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.ec2.AmazonEC2Client;
import com.amazonaws.services.ec2.model.AuthorizeSecurityGroupIngressRequest;
import com.amazonaws.services.ec2.model.CreateKeyPairRequest;
import com.amazonaws.services.ec2.model.CreateKeyPairResult;
import com.amazonaws.services.ec2.model.CreateSecurityGroupRequest;
import com.amazonaws.services.ec2.model.CreateTagsRequest;
import com.amazonaws.services.ec2.model.DeleteKeyPairRequest;
import com.amazonaws.services.ec2.model.DeleteSecurityGroupRequest;
import com.amazonaws.services.ec2.model.DescribeInstancesRequest;
import com.amazonaws.services.ec2.model.DescribeInstancesResult;
import com.amazonaws.services.ec2.model.Instance;
import com.amazonaws.services.ec2.model.InstanceState;
import com.amazonaws.services.ec2.model.InstanceStateName;
import com.amazonaws.services.ec2.model.IpPermission;
import com.amazonaws.services.ec2.model.KeyPair;
import com.amazonaws.services.ec2.model.Reservation;
import com.amazonaws.services.ec2.model.RunInstancesRequest;
import com.amazonaws.services.ec2.model.RunInstancesResult;
import com.amazonaws.services.ec2.model.StartInstancesRequest;
import com.amazonaws.services.ec2.model.Tag;
import com.amazonaws.services.ec2.model.TerminateInstancesRequest;
import com.jcraft.jsch.JSchException;
import enumeration.NodeType;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.Set;
import main.SCUtils;

/**
 *
 * @author Daniel, Vítor
 */
public class AmazonProvider {

    String accesskey = new String();
    String secretaccesskey = new String();
    static Random rand = new Random();
    KeyPair keyPair;
    private String ReservationId;
    public AmazonEC2Client client;

    public AmazonProvider(String key, String secretkey) throws IOException, FileNotFoundException, InterruptedException {
        accesskey = key;
        secretaccesskey = secretkey;
        client = startProvider();
    }

    public AmazonEC2Client startProvider() throws FileNotFoundException, IOException, InterruptedException {
        String credentialsFile = "credentials.sc";
        FileWriter writer = new FileWriter(new File(credentialsFile), true);
        PrintWriter saida = new PrintWriter(writer);
        saida.println("secretKey=" + secretaccesskey);
        saida.println("accessKey=" + accesskey);
        saida.close();
        writer.close();

        File f = new File(credentialsFile);
        FileInputStream fis = new FileInputStream(f);

        AWSCredentials credentials = new PropertiesCredentials(fis);
        AmazonEC2Client ec2 = new AmazonEC2Client(credentials);
        SCUtils.deleteFile(credentialsFile,".");

        ec2.setRegion(Region.getRegion(Regions.US_WEST_2));
        return ec2;
    }

    public void createCluster(XMLReader configurationFile, String absolutePath) throws Exception {
        boolean hasAliveInstance = SCUtils.hasAliveInstanceFromCluster(client, configurationFile.clusterName);
        boolean hasSecurityGroup = SCUtils.hasAliveSecurityGroupFromCluster(client, configurationFile);
        boolean hasKeyPairGroup = SCUtils.hasAliveKeyPairFromCluster(client, configurationFile);

        if(!hasAliveInstance && !hasSecurityGroup && !hasKeyPairGroup){
            //configurationFile.vmTypes.get(0).setAmountInstantiatedVM(1);

            SCUtils.printFirstLevel("PGStarter is communicating with Amazon...");
            createSecurityGroup(client, configurationFile.clusterName);
            createKeyPair(client, configurationFile.clusterName);

            SCUtils.printFirstLevel("Creating pool of virtual machines...");
            List<AmazonMachine> machines = startVirtualMachines(configurationFile.vmTypes, 
                    configurationFile, client);

            for (AmazonMachine mac : machines) {
                SCUtils.printSecondLevel(mac.toString());
            }
            SCUtils.printFirstLevel("Amount of Virtual machines = " + machines.size());
        }else{
            SCUtils.printSecondLevel("There is an alive instance with this cluster name!");
        }
    }

    public List<AmazonMachine> startVirtualMachines(List<VirtualMachineType> vmTypes, 
            XMLReader configurationFile, AmazonEC2Client amazon) 
            throws InterruptedException, IOException {
        List<RunInstancesResult> results = new ArrayList<RunInstancesResult>();
        RunInstancesRequest rir;
        RunInstancesResult result = null;
        List<Instance> resultInstance;
        List<AmazonMachine> machines = new ArrayList<AmazonMachine>();
        List<String> resources = new LinkedList<String>();
        List<String> currentResource = new LinkedList<String>();
        List<String> instanceIds = new LinkedList<String>();
        DescribeInstancesResult describeInstancesRequest;
        List<Reservation> reservations;
        List<Tag> tags = new LinkedList<Tag>();
        CreateTagsRequest ctr;
        Set instances = new HashSet();
        Tag nameTag;
        String createdInstanceId = new String();
        StartInstancesRequest startIR;
        int rank = 0;
        int i, k = 0;
        int controlType = 0;
        VirtualMachineType vmType;

        for (VirtualMachineType vmTypeLoop : vmTypes) {
            if (vmTypeLoop.getAmountInstantiatedVM() > 0) {
                rir = new RunInstancesRequest(configurationFile.image, vmTypeLoop.getAmountInstantiatedVM(), vmTypeLoop.getAmountInstantiatedVM());
                rir.setInstanceType(vmTypeLoop.getType());
                rir.setKeyName(SCUtils.getKeyPairName(configurationFile.clusterName));
                rir.setSecurityGroups(SCUtils.getSecurityGroupList(configurationFile.clusterName));
                result = amazon.runInstances(rir);
                results.add(result);
            }
        }

        /**
         * Aguardando as VMs estarem no ar
         */
        SCUtils.printSecondLevel("PGStarter is waiting virtual machines to start...");
        SCUtils.sleep(30000);
        SCUtils.printSecondLevel("All virtual machines are instantiated!");

        boolean hasControlInstances = SCUtils.hasControlInstanceFromCluster(amazon, configurationFile.clusterName);
        boolean hasCoreInstances = SCUtils.hasCoreInstanceFromCluster(amazon, configurationFile.clusterName);
        boolean first = true;
        nameTag = new Tag(SCUtils.clusterLabelName, SCUtils.getVirtualMachinesName(configurationFile.clusterName));
        for (RunInstancesResult res : results) {
            resultInstance = res.getReservation().getInstances();
            
            Tag nodeTypeTag;
            for (Instance ins : resultInstance) {
                currentResource = new LinkedList<String>();
                createdInstanceId = ins.getInstanceId();
                SCUtils.printSecondLevel("New virtual machine has been created: " + ins.getInstanceId()); //print the instance ID
                resources.add(createdInstanceId);
                currentResource.add(createdInstanceId);
                instanceIds.add(createdInstanceId);
                
                tags = new LinkedList<Tag>();
                tags.add(nameTag);
                if(!hasControlInstances && first){
                    nodeTypeTag = new Tag(SCUtils.clusterNodeType, NodeType.CONTROL.toString());
                    first = false;
                }else if(!hasCoreInstances && first){
                    nodeTypeTag = new Tag(SCUtils.clusterNodeType, NodeType.SUPERNODE.toString());
                    first = false;
                }else{
                    nodeTypeTag = new Tag(SCUtils.clusterNodeType, NodeType.NODE.toString());
                }
                tags.add(nodeTypeTag);
                ctr = new CreateTagsRequest(currentResource, tags);
                amazon.createTags(ctr);
            }

            ReservationId = res.getReservation().getReservationId();
            describeInstancesRequest = amazon.describeInstances();
            reservations = describeInstancesRequest.getReservations();
            
            for (Reservation reservation : reservations) {
                instances.addAll(reservation.getInstances());
                if (reservation.getReservationId().equals(this.ReservationId)) {
                    k = reservation.getInstances().size();
                    vmType = vmTypes.get(controlType);
                    while (vmType.getAmountInstantiatedVM() < 1) {
                        controlType++;
                        vmType = vmTypes.get(controlType);
                    }
                    
                    for (i = 0; i < k; i++) {
                        machines.add(new AmazonMachine(rank, reservation.getInstances().get(i).getPublicDnsName(), 
                                reservation.getInstances().get(0).getPublicIpAddress(), 
                                reservation.getInstances().get(0).getPrivateIpAddress(), 
                                vmType.getType(), vmType.getNumberOfCores()));
                        rank++;
                        controlType++;
                    }
                }
            }

            startIR = new StartInstancesRequest(instanceIds);
            amazon.startInstances(startIR);
        }
        
        return machines;
    }
    
    private Instance searchByName(String name) {
        
        List<Instance> instances = new ArrayList<>(verifyExistingMachines(client));
        
        for (Instance ins : instances) {
            for (Tag tag : ins.getTags()) {
                if (tag.getKey().equals(SCUtils.clusterLabelName) && 
                        tag.getValue().equalsIgnoreCase(name)) {
                    return ins;
                }
            }
        }
        return null;
    }
    
    private Instance refresh(String instanceId) {
        Set<Instance> instances = verifyExistingMachines(client, instanceId);
        if (!instances.isEmpty()){
            return instances.iterator().next();
        }
        return null;
    }
    
    public void startPargresService() throws IOException, JSchException, InterruptedException {
        
        Instance cqpServer = searchByName("CQP_SERVER");
        
        if (cqpServer != null) {
            
            int count = 0;
            
            while ((InstanceStateName.Pending.name().equalsIgnoreCase(cqpServer.getState().getName()) ||
                    InstanceStateName.ShuttingDown.name().equalsIgnoreCase(cqpServer.getState().getName()) ||
                    InstanceStateName.Stopping.name().equalsIgnoreCase(cqpServer.getState().getName()))
                    && count <= 20) {
                Thread.sleep(1000);
                cqpServer = refresh(cqpServer.getInstanceId());
                count++;
            }
            
            if (InstanceStateName.Stopped.name().equalsIgnoreCase(cqpServer.getState().getName())) {
                
                StartInstancesRequest startIR = new StartInstancesRequest(Arrays.asList(cqpServer.getInstanceId()));
                client.startInstances(startIR);
                cqpServer = refresh(cqpServer.getInstanceId());
                
                count = 0;
            
                while (InstanceStateName.Pending.name().equalsIgnoreCase(cqpServer.getState().getName()) && count <= 20) {
                    Thread.sleep(1500);
                    cqpServer = refresh(cqpServer.getInstanceId());
                    count++;
                }
            } 
            
            if (InstanceStateName.Terminated.name().equalsIgnoreCase(cqpServer.getState().getName())) {
                SCUtils.printFirstLevel("CQP Instance has been terminated!");
            }
            
            if (InstanceStateName.Running.name().equalsIgnoreCase(cqpServer.getState().getName())) {
            
                SCUtils.runRemmoteCommand("kill $(ps aux | grep '[j]ava' | awk '{print $2}')", cqpServer);
                Thread.sleep(1500);

                SCUtils.runRemmoteCommand("nohup ./nqp.sh &> nohup_nqp.out&", cqpServer);
                Thread.sleep(5000);

                SCUtils.runRemmoteCommand("nohup ./cqp.sh &> nohup_cqp.out&", cqpServer);
                Thread.sleep(10000);

                List<Instance> instances = new ArrayList<>(verifyExistingMachines(client));

                String command = "./add_nodes.sh";
                for (Instance inst : instances) {
                    if(!inst.getInstanceId().equalsIgnoreCase(cqpServer.getInstanceId())) {
                        command += " " + inst.getPrivateIpAddress();
                    }
                }
                SCUtils.runRemmoteCommand(command, cqpServer);
                
                SCUtils.printFirstLevel("Finished adding nodes.");

                SCUtils.runRemmoteCommand("./list_nodes.sh", cqpServer);
                
            }
        }
    }
    
    public String createKeyPair(AmazonEC2Client amazon, String clusterName) throws IOException {
        String keyName = SCUtils.getKeyPairName(clusterName);
        
        CreateKeyPairRequest newKeyRequest = new CreateKeyPairRequest();
        newKeyRequest.setKeyName(keyName);
        CreateKeyPairResult keyresult = amazon.createKeyPair(newKeyRequest);

        keyPair = keyresult.getKeyPair();
        SCUtils.printSecondLevel("The key PGStarter created is = " + keyPair.getKeyName());
//        System.out.println("The key PGStarter created is = "
//                + keyPair.getKeyName() + "\nIts fingerprint is="
//                + keyPair.getKeyFingerprint() + "\nIts material is= \n"
//                + keyPair.getKeyMaterial());

        File distFile = new File(keyName + ".pem");
        BufferedReader bufferedReader = new BufferedReader(new StringReader(keyPair.getKeyMaterial()));
        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(distFile));
        char buf[] = new char[1024];
        int len;
        while ((len = bufferedReader.read(buf)) != -1) {
            bufferedWriter.write(buf, 0, len);
        }
        bufferedWriter.flush();
        bufferedReader.close();
        bufferedWriter.close();
        return keyName;

    }

    public Set<Instance> verifyExistingMachines(AmazonEC2Client amazon) {
        
        return verifyExistingMachines(amazon, null);
    }
    
    public Set<Instance> verifyExistingMachines(AmazonEC2Client amazon, String instanceId) {
        
        SCUtils.printFirstLevel("#5 Describing Current Instances");
        
        DescribeInstancesResult describeInstancesResult;
        
        if (instanceId != null) {
            DescribeInstancesRequest describeInstancesRequest = new DescribeInstancesRequest();
            describeInstancesRequest.setInstanceIds(Arrays.asList(instanceId));
            
            describeInstancesResult = amazon.describeInstances(describeInstancesRequest);
            
        } else {
            describeInstancesResult = amazon.describeInstances();
        }
        
        List<Reservation> reservations = describeInstancesResult.getReservations();
        
        Set<Instance> instances = new HashSet<Instance>();
        // add all instances to a Set.
        for (Reservation reservation : reservations) {
            instances.addAll(reservation.getInstances());
        }

        SCUtils.printFirstLevel("You have " + instances.size() + " Amazon EC2 instance(s).");
        for (Instance ins : instances) {
            // instance id
            String instId = ins.getInstanceId();
            // instance state
            InstanceState is = ins.getState();
            SCUtils.printSecondLevel(instId + " " + is.getName() + " " + ins.getPublicDnsName());
        }
        
        return instances;

    }

    public String createSecurityGroup(AmazonEC2Client amazon, String clusterName) {
        String newGroupName = SCUtils.getSecurityGroupName(clusterName); //name of the group
        CreateSecurityGroupRequest r1 = new CreateSecurityGroupRequest(newGroupName, "PGStarter temporal group");
        amazon.createSecurityGroup(r1);
        AuthorizeSecurityGroupIngressRequest r2 = new AuthorizeSecurityGroupIngressRequest();
        r2.setGroupName(newGroupName);

        /**
         * *********** http****************
         */
        IpPermission permission = new IpPermission();
        permission.setIpProtocol("tcp");
        permission.setFromPort(80);
        permission.setToPort(80);
        List<String> ipRanges = new ArrayList<String>();
        ipRanges.add("0.0.0.0/0");
        permission.setIpRanges(ipRanges);

        /**
         * *********** SSH*********************
         */
        IpPermission permission1 = new IpPermission();
        permission1.setIpProtocol("tcp");
        permission1.setFromPort(22);
        permission1.setToPort(22);
        List<String> ipRanges1 = new ArrayList<String>();
        ipRanges1.add("0.0.0.0/0");
        permission1.setIpRanges(ipRanges1);

        /**
         * *********** https*********************
         */
        IpPermission permission2 = new IpPermission();
        permission2.setIpProtocol("tcp");
        permission2.setFromPort(443);
        permission2.setToPort(443);
        List<String> ipRanges2 = new ArrayList<String>();
        ipRanges2.add("0.0.0.0/0");
        permission2.setIpRanges(ipRanges2);

        /**
         * ***********mensagens tcp*********************
         */
        IpPermission permission3 = new IpPermission();
        permission3.setIpProtocol("tcp");
        permission3.setFromPort(0);
        permission3.setToPort(65535);
        List<String> ipRanges3 = new ArrayList<String>();
        ipRanges3.add("0.0.0.0/0");
        permission3.setIpRanges(ipRanges3);

        /**
         * ********************Adicionando as regras********************
         */
        List<IpPermission> permissions = new ArrayList<IpPermission>();
        permissions.add(permission);
        permissions.add(permission1);
        permissions.add(permission2);
        permissions.add(permission3);
        r2.setIpPermissions(permissions);

        amazon.authorizeSecurityGroupIngress(r2);
        return newGroupName;
    }

    public void deleteCluster(XMLReader configurationFile) throws InterruptedException {
        LinkedList<String> instanceIds = new LinkedList<String>();
        
//        to get instance ids
        {
            DescribeInstancesResult result = SCUtils.getAliveInstancesFromCluster(client, configurationFile.clusterName);
            SCUtils.printFirstLevel("Removing instances from cluster " + configurationFile.clusterName + " ...");
            List<Reservation> reservations = result.getReservations();
            if(!reservations.isEmpty()){
                for (Reservation reservation : reservations) {
                    List<Instance> instances = reservation.getInstances();
                    for (Instance instance : instances) {
                        instanceIds.add(instance.getInstanceId());
                        SCUtils.printSecondLevel(instance.getInstanceId() + " ...");
                    }
                }
            }else{
                SCUtils.printSecondLevel("There is not any instance in this cluster!");
            }
        }
        
        if(!instanceIds.isEmpty()){
            TerminateInstancesRequest terminateInstances = new TerminateInstancesRequest(instanceIds);
            client.terminateInstances(terminateInstances);
        }
        
//        to check instances after termination
        while(SCUtils.hasFinishedInstancesFromCluster(client, configurationFile.clusterName)){
            SCUtils.sleep();
        }
        
        DeleteKeyPairRequest kpRequest = new DeleteKeyPairRequest(SCUtils.getKeyPairName(configurationFile.clusterName));
        client.deleteKeyPair(kpRequest);

        DeleteSecurityGroupRequest scRequest = new DeleteSecurityGroupRequest(SCUtils.getSecurityGroupName(configurationFile.clusterName));
        try{
            client.deleteSecurityGroup(scRequest);
        }catch(Exception ex){
            SCUtils.printSecondLevel("This security group was already removed!");
        }
    }

    public void shutDownProvider() {
        client.shutdown();
    }

    public void allocateVirtualMachines(XMLReader configurationFile, ArrayList<VirtualMachineType> machinesToAllocate) throws InterruptedException, IOException {
        if(!machinesToAllocate.isEmpty()){
            SCUtils.printFirstLevel("Allocating new virtual machines in cluster " + configurationFile.clusterName + "...", configurationFile.verbose);
            startVirtualMachines(machinesToAllocate, configurationFile, client);
                
            if (configurationFile.uploadBinary) {
                SCUtils.uploadBinaryFiles(client, configurationFile);
            }
        }
    }

    public void deallocateVirtualMachines(XMLReader configurationFile, ArrayList<VirtualMachineType> machinesToDeallocate) {
        if(!machinesToDeallocate.isEmpty()){
            boolean hasAliveInstance = SCUtils.hasCoreInstanceFromCluster(client, configurationFile.clusterName);

            if(hasAliveInstance){
                SCUtils.printFirstLevel("Deallocating virtual machines in cluster " + configurationFile.clusterName + "...", configurationFile.verbose);
                finishVirtualMachines(machinesToDeallocate, configurationFile, configurationFile.image, client);
            }
        }
    }

    private void finishVirtualMachines(ArrayList<VirtualMachineType> machinesToDeallocate, XMLReader configurationFile, String image, AmazonEC2Client amazonClient) {
        LinkedList<String> instanceIds = new LinkedList<>();
//        to get instance ids
        for(VirtualMachineType vmType : machinesToDeallocate){
            int numberOfDeallocations = vmType.getAmountInstantiatedVM();
            
            DescribeInstancesResult result = SCUtils.getAliveInstancesFromClusterByType(amazonClient, configurationFile, vmType);
            SCUtils.printFirstLevel("Removing " + vmType.getAmountInstantiatedVM() 
                    + " instances of type " + vmType.getType() 
                    + " from cluster " + configurationFile.clusterName + "...");
            List<Reservation> reservations = result.getReservations();
            
            if(!reservations.isEmpty()){
                for (Reservation reservation : reservations) {
                    List<Instance> instances = reservation.getInstances();
                    for (Instance instance : instances) {
                        if(numberOfDeallocations > 0){
                            instanceIds.add(instance.getInstanceId());
                            SCUtils.printSecondLevel(instance.getInstanceId() + " ...");
                            numberOfDeallocations--;
                        }
                    }
                }
                
                TerminateInstancesRequest terminateInstances = new TerminateInstancesRequest(instanceIds);
                amazonClient.terminateInstances(terminateInstances);
            }else{
                SCUtils.printSecondLevel("There is not any instance in this cluster!");
            }
        }
    }
    
}
