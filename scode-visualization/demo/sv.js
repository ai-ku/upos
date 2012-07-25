var camera, scene, renderer, dirLight, control;
var scode_geometry, scode_material, scode_mesh, input_text, text_mesh, blocking_sphere;
var frame_counter, play_scode;
var bg_color, text_color_2d, text_color_3d, clustering_color, clustering_id;

init();
animate();

function init() {
    frame_counter = 0;
    play_scode = false;
    input_text = "";
    text_mesh = [];
    clustering_color = 6;
    scene = new THREE.Scene();
    init_camera();
    init_lights();
    init_control();
    init_scode_mesh();
    init_renderer();
    toggle_colors();
    toggle_clusters();
}

function init_renderer() {
    renderer = new THREE.WebGLRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.getElementById("container").appendChild( renderer.domElement );
}

function init_scode_mesh() {
    if (scode_mesh) {
	scene.remove(scode_mesh);
    }
    scode_geometry = new THREE.Geometry();
    for (var i = 0; i < ver_initial.length; i++) {
	var v = ver_initial[i];
	scode_geometry.vertices.push(new THREE.Vector3(v[1], v[2], v[3]));
	scode_geometry.colors.push(new THREE.Color(parseInt(v[clustering_color], 16)));
    }
    scode_material = new THREE.ParticleBasicMaterial(
	{size: 3, vertexColors: THREE.VertexColors, depthTest: true, opacity: 1, sizeAttenuation: false});
    scode_mesh = new THREE.ParticleSystem(scode_geometry, scode_material);
    scode_mesh.geometry.dynamic = true;
    scode_mesh.dynamic = true;
    scene.add(scode_mesh);
}

function make_blocking_sphere() {
    if (blocking_sphere) {
	scene.remove(blocking_sphere);
    }
    var geometry = new THREE.SphereGeometry(500, 20, 20);
    var material = new THREE.MeshBasicMaterial({color: parseInt(bg_color, 16)});
    blocking_sphere = new THREE.Mesh(geometry, material);
    scene.add(blocking_sphere);
}

function init_control() {
    controls = new THREE.TrackballControls( camera );
    controls.target.set( 0, 0, 0 );
    controls.rotateSpeed = 0.1;
    controls.dynamicDampingFactor = 1;
    controls.noZoom = true;
    controls.noPan = true;
}

function init_lights() {
    dirLight = new THREE.DirectionalLight( 0xffffff, 0.8 );
    dirLight.position.set( 0, 0, 1 ).normalize();
    scene.add( dirLight );
    var ambient = new THREE.AmbientLight( 0x505050 );
    scene.add( ambient );
}

function init_camera() {
    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 );
    camera.position.z = 1000;
    scene.add( camera );
}

function initial_button() {
    for (var i = 0; i < ver_initial.length; i++) {
	var v = ver_initial[i];
	scode_geometry.vertices[v[0]] = new THREE.Vector3(v[1], v[2], v[3]);
    }
    scode_mesh.geometry.verticesNeedUpdate = true;
    update_texts();
}

function start_button() {
    restart_geometry();
    play_scode = true;
    document.getElementById("StartButton").disabled = true;
    document.getElementById("InitialButton").disabled = true;
}

function show_button() {
    input_text = prompt("Enter some words", input_text);
    replace_texts();
    update_texts();
}

function replace_texts() {
    var types = input_text.split(" ");
    var m;
    while (m = text_mesh.pop()) {
	scene.remove(m.mesh);
    }
    for (var i = 0; i < types.length; i++) {
	if (word_index[types[i]] != undefined) {
	    m = make_text_mesh(types[i]);
	    text_mesh.push({mesh:m, index:word_index[types[i]], type:types[i]});
	    var target = scode_mesh.geometry.vertices[word_index[types[i]]];
	    m.lookAt(target);
	    m.position = new THREE.Vector3(target.x * 1.01, target.y * 1.01, target.z * 1.01);
	    scene.add(m);
	}
    }
}

function update_texts () {
    var update_string = "";
    for (var i = 0; i < text_mesh.length; i++) {
	var mesh = text_mesh[i].mesh;
	var index = text_mesh[i].index;
	var target = scode_mesh.geometry.vertices[index];
	mesh.position = new THREE.Vector3(0, 0, 0);
	mesh.lookAt(target);
	mesh.position = new THREE.Vector3(target.x * 1.01, target.y * 1.01, target.z * 1.01);
	var v = ver_initial[index];
	update_string += "<div align='center' style='vertical-align:middle;color:#ffffff;background-color:#" + v[clustering_color]  + ";width:24px;height:15px;float: left;'>" + v[clustering_id] + "</div>" + text_mesh[i].type  + "<br>";
    }
    document.getElementById("legend").innerHTML = update_string;
}

function restart_geometry() {
    for (var i = 0; i < ver_initial.length; i++) {
	var v = ver_initial[i];
	scode_geometry.vertices[v[0]].x = v[1];
	scode_geometry.vertices[v[0]].y = v[2];
	scode_geometry.vertices[v[0]].z = v[3];
    }
    scode_mesh.geometry.verticesNeedUpdate = true;
}

function animate() {
    if (play_scode) {
	if (frame_counter != n_updates) {
	    update_geometry(frame_counter);
	    update_texts();
	    frame_counter++;
	} else {
	    play_scode = false;
	    document.getElementById("StartButton").disabled = false;
	    document.getElementById("InitialButton").disabled = false;
	    frame_counter = 0;
	}
    }
    requestAnimationFrame(animate);
    controls.update();
    render();
}

function update_geometry(frame) {
    var ver = ver_updates[frame];
    for (var i = 0; i < ver.length; i++) {
	var v = ver[i];
	scode_geometry.vertices[v[0]].x = v[1];
	scode_geometry.vertices[v[0]].y = v[2];
	scode_geometry.vertices[v[0]].z = v[3];
    }
    scode_mesh.geometry.verticesNeedUpdate = true;
}

function render() {
    dirLight.position.set( camera.position.x, camera.position.y, camera.position.z ).normalize();
    renderer.render( scene, camera );
}

function create_line(start, end) {
    var lineMat = new THREE.LineBasicMaterial( { color: 0x0000ff, opacity: 1, linewidth: 3 } );

    var geom = new THREE.Geometry();
    geom.vertices.push( start );
    geom.vertices.push( end );

    var line = new THREE.Line(geom, lineMat);
    return line;
}

function make_text_mesh(text) {
    var faceMaterial = new THREE.MeshFaceMaterial();
    var textMaterialFront = new THREE.MeshPhongMaterial( { color: parseInt(text_color_3d, 16), shading: THREE.FlatShading } );
    var textMaterialSide = new THREE.MeshPhongMaterial( { color: parseInt(text_color_3d, 16), shading: THREE.SmoothShading } );

    var textGeo = new THREE.TextGeometry(text, {
	size: 40,
	height: 10,
	curverSegments: 4,

	font: "helvetiker",
	weight: "normal",
	style: "normal",

	bevelThickness: 2,
	bevelSize: 1.5,
	bevelEnabled: false,

	bend: false,

	material: 0,
	extrudeMaterial: 1});

    textGeo.materials = [textMaterialFront, textMaterialSide];
    textGeo.computeBoundingBox();
    textGeo.computeVertexNormals();
    THREE.GeometryUtils.center(textGeo);
    return new THREE.Mesh(textGeo, faceMaterial);
}

function toggle_colors() {
    if (bg_color === "000000") {
	bg_color = "ffffff";
	text_color_2d = "000000";
	text_color_3d = "ff0000";
    } else {
	bg_color = "000000";
	text_color_2d = "ffffff";
	text_color_3d = "ffffff";
    }
    replace_texts();
    update_texts();
    document.getElementById("legend").style.color = "#" + text_color_2d;
    document.body.style.backgroundColor = "#" + bg_color;
    make_blocking_sphere();
}

function toggle_clusters() {
//    clustering_color = 4;
    if (clustering_color === 4) {
	clustering_color = 6;
	clustering_id = 7;
	document.getElementById("ToggleClusters").innerHTML = "KMeans";
    } else {
	clustering_color = 4;
	clustering_id = 5;
	document.getElementById("ToggleClusters").innerHTML = "Gold";
    }
    for (var i = 0; i < ver_initial.length; i++) {
	var v = ver_initial[i];
	var c = scode_mesh.geometry.colors[v[0]];
	c.r = parseInt(v[clustering_color].slice(0, 2), 16) / 255;
	c.g = parseInt(v[clustering_color].slice(2, 4), 16) / 255;
	c.b = parseInt(v[clustering_color].slice(4, 6), 16) / 255;
    }
    scode_mesh.geometry.colorsNeedUpdate = true;
    update_texts();
}
