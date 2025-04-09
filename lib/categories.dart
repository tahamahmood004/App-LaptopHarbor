import 'package:bookstore/ProductDetailPage.dart';
import 'package:bookstore/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class categoriespage extends StatefulWidget {
final String catid;
  const categoriespage({super.key,required this.catid});

  @override
  State<categoriespage> createState() => _categoriespageState();
}

class _categoriespageState extends State<categoriespage> {
    List<Map<String, dynamic>> products = [];

@override
void fetchProducts() async {
  final data = await FirebaseFirestore.instance
      .collection('products')
      .where('cat_id', isEqualTo: widget.catid)
      .get();

  setState(() {
    products = data.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
        print(products);
  });
}
  
  void initState() {
    super.initState();
    fetchProducts();
  }
     
            
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
  onPressed: () {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => myapp()));
  },
  icon: Icon(Icons.arrow_back, color: Colors.white), // White color added
),
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              "🚚 Free Delivery on Orders Above Rs.1,999/-",
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              speed: Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text('PRODUCTS',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Color.fromARGB(255, 24, 16, 133))),
              SizedBox(height: 20),
              products.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.60,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        return Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  product['b_img'] ?? 'https://via.placeholder.com/150',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      product['b_name'] ?? 'No Name',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Color.fromARGB(255, 4, 66, 85)),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "\$${product['price'] ?? '0.00'}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Color.fromARGB(255, 4, 66, 85)),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
builder: (context) => ProductDetailPage(product:product),

      ),
    );
  },
  child: Text('See Details', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 14)),
  style: ElevatedButton.styleFrom(
    backgroundColor:Color.fromARGB(255, 24, 16, 133),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
